#include <core.p4>
#define V1MODEL_VERSION 20180101
#include <v1model.p4>

header hdr {
    bit<8>  op;
    bit<8>  opr1_8;
    bit<8>  opr2_8;
    bit<8>  res_8;
    int<16> opr1_16;
    int<16> opr2_16;
    int<16> res_16;
}

struct Header_t {
    hdr h;
}

struct Meta_t {
}

parser p(packet_in b, out Header_t h, inout Meta_t m, inout standard_metadata_t sm) {
    state start {
        b.extract<hdr>(h.h);
        transition accept;
    }
}

control vrfy(inout Header_t h, inout Meta_t m) {
    apply {
    }
}

control update(inout Header_t h, inout Meta_t m) {
    apply {
    }
}

control egress(inout Header_t h, inout Meta_t m, inout standard_metadata_t sm) {
    apply {
    }
}

control deparser(packet_out b, in Header_t h) {
    apply {
        b.emit<hdr>(h.h);
    }
}

control ingress(inout Header_t h, inout Meta_t m, inout standard_metadata_t standard_meta) {
    @name("ingress.usat_plus") action usat_plus() {
        standard_meta.egress_spec = 9w0;
        h.h.res_8 = h.h.opr1_8 |+| h.h.opr2_8;
    }
    @name("ingress.usat_minus") action usat_minus() {
        standard_meta.egress_spec = 9w0;
        h.h.res_8 = h.h.opr1_8 |-| h.h.opr2_8;
    }
    @name("ingress.sat_plus") action sat_plus() {
        standard_meta.egress_spec = 9w0;
        h.h.res_16 = h.h.opr1_16 |+| h.h.opr2_16;
    }
    @name("ingress.sat_minus") action sat_minus() {
        standard_meta.egress_spec = 9w0;
        h.h.res_16 = h.h.opr1_16 |-| h.h.opr2_16;
    }
    @name("ingress.drop") action drop() {
        mark_to_drop(standard_meta);
    }
    @name("ingress.t") table t_0 {
        key = {
            h.h.op: exact @name("h.h.op") ;
        }
        actions = {
            usat_plus();
            usat_minus();
            sat_plus();
            sat_minus();
            drop();
        }
        default_action = drop();
        const entries = {
                        8w0x1 : usat_plus();
                        8w0x2 : usat_minus();
                        8w0x3 : sat_plus();
                        8w0x4 : sat_minus();
        }
    }
    apply {
        t_0.apply();
    }
}

V1Switch<Header_t, Meta_t>(p(), vrfy(), ingress(), egress(), update(), deparser()) main;

