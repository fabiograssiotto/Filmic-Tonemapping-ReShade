Code changed to allow for HDR color spaces. For now it supports scRGB and HDR10 PQ on the Narkowicz shader.

This code is modified from https://github.com/Zackin5/Filmic-Tonemapping-ReShade.

# Filmic-Tonemapping-ReShade
Gamma-correct filmic tonemapping shaders for ReShade. Includes the Uncharted 2 tonemap, a simplified Haarm-Pieter Duiker and different variants on ACES and Reinhard implementations.

## Credits
Inspiration and code came from the following works:

* [John Hable - Filmic Tonemapping Operators](http://filmicworlds.com/blog/filmic-tonemapping-operators/)
* [John Hable - Uncharted 2: HDR Lighting](http://www.gdcvault.com/play/1012351/Uncharted-2-HDR)
* [Tom Madams - Why Reinhard desaturates my blacks](https://imdoingitwrong.wordpress.com/2010/08/19/why-reinhard-desaturates-my-blacks-3/)
* [Krzysztof Narkowicz - ACES Filmic Tone Mapping Curve](https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/)
