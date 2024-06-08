#ifndef _ASSETS_SPONZA_H_
#define _ASSETS_SPONZA_H_ 1

#include <stdint.h>

struct sponza_vertex_position_t
{
    float x;
    float y;
    float z;
};

extern struct sponza_vertex_position_t sponza_vertex_positions[533055];
extern uint32_t sponza_indices[786801];

#endif
