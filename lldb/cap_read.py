"""Cap SBProcess.ReadMemory so Rust pretty-printers can't read gigabytes.

rustlib's lldb_providers.py reads `length` bytes for every &str / Path with no
upper bound. In stale async-state variants `length` is garbage (often GBs), so
codelldb allocates ~12 GB and appears to hang. Refuse oversized reads instead.
"""
import lldb

_MAX_READ = 1 << 20  # 1 MiB

if not getattr(lldb.SBProcess.ReadMemory, "_capped", False):
    _orig = lldb.SBProcess.ReadMemory

    def _capped(self, addr, size, error):
        if size > _MAX_READ:
            error.SetErrorString("read of %d bytes refused (garbage length?)" % size)
            return None
        return _orig(self, addr, size, error)

    _capped._capped = True
    lldb.SBProcess.ReadMemory = _capped

# Same problem for loops: vec_to_string / sequence_formatter iterate
# range(valobj.GetNumChildren()), creating one SBValue per element. A garbage
# length makes that loop effectively endless and eats RAM. Cap the no-arg form.
_MAX_CHILDREN = 1000

if not getattr(lldb.SBValue.GetNumChildren, "_capped", False):
    _orig_children = lldb.SBValue.GetNumChildren

    def _capped_children(self, *args):
        if args:
            return _orig_children(self, *args)
        return _orig_children(self, _MAX_CHILDREN)

    _capped_children._capped = True
    lldb.SBValue.GetNumChildren = _capped_children
    lldb.SBValue.num_children = property(_capped_children)

# Recursion: StructSummaryProvider -> aggregate_field_summary -> child.summary
# -> StructSummaryProvider ... has no depth limit, so big graphs (Arc / dyn /
# pools / HashMaps) are walked to the bottom. Stop nested summaries at a depth.
_MAX_DEPTH = 4
_depth = 0

if not getattr(lldb.SBValue.GetSummary, "_capped", False):
    _orig_summary = lldb.SBValue.GetSummary

    def _capped_summary(self, *args):
        global _depth
        if _depth >= _MAX_DEPTH:
            return "{...}"
        _depth += 1
        try:
            return _orig_summary(self, *args)
        finally:
            _depth -= 1

    _capped_summary._capped = True
    lldb.SBValue.GetSummary = _capped_summary
    # `child.summary` is a property bound to the ORIGINAL function; replace it too.
    lldb.SBValue.summary = property(_capped_summary)

# TEMP diagnostic: `kill -USR1 <codelldb pid>` dumps the Python stack of every
# thread to ~/.local/state/nvim/lldb-trace.log, even while a formatter is
# spinning, so a runaway pretty-printer can be named.
try:
    import faulthandler, os, signal

    _trace = open(os.path.expanduser("~/.local/state/nvim/lldb-trace.log"), "a")
    faulthandler.register(signal.SIGUSR1, file=_trace, all_threads=True)
except Exception:
    pass
