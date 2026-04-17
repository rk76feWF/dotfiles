"""MLX LM server with TurboQuant KV cache compression."""

import sys

# Monkey-patch make_prompt_cache before importing server
from mlx_lm.models import cache as cache_module
from turboquant_mlx.v_only_cache import VOnlyTurboQuantCache

_original_make_prompt_cache = cache_module.make_prompt_cache


def _turboquant_make_prompt_cache(model, max_kv_size=None):
    num_layers = len(model.layers)
    return [VOnlyTurboQuantCache(bits=3) for _ in range(num_layers)]


cache_module.make_prompt_cache = _turboquant_make_prompt_cache

# Now start the server
from mlx_lm.server import main

main()
