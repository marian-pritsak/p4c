#include <core.p4>
#define V1MODEL_VERSION 20180101
#include <v1model.p4>

header Ethernet_h {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

header Ipv4_h {
    bit<4>  version;
    bit<4>  ihl;
    bit<8>  diffserv;
    bit<16> totalLen;
    bit<16> identification;
    bit<3>  flags;
    bit<13> fragOffset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}

struct Headers {
    Ethernet_h ethernet;
    Ipv4_h     ip;
}

struct Metadata {
}

parser P(packet_in b, out Headers p, inout Metadata meta, inout standard_metadata_t standard_meta) {
    state start {
        transition accept;
    }
}

control Ing(inout Headers headers, inout Metadata meta, inout standard_metadata_t standard_meta) {
    @name("Ing.n") bit<8> n_0;
    @name("Ing.debug") register<bit<8>>(32w2) debug_0;
    @hidden action slicedefuse79() {
        n_0 = 8w0b11111111;
        n_0[7:4] = 4w0;
        debug_0.write(32w1, n_0);
        standard_meta.egress_spec = 9w0;
    }
    @hidden table tbl_slicedefuse79 {
        actions = {
            slicedefuse79();
        }
        const default_action = slicedefuse79();
    }
    apply {
        tbl_slicedefuse79.apply();
    }
}

control Eg(inout Headers hdrs, inout Metadata meta, inout standard_metadata_t standard_meta) {
    apply {
    }
}

control DP(packet_out b, in Headers p) {
    apply {
        b.emit<Ethernet_h>(p.ethernet);
        b.emit<Ipv4_h>(p.ip);
    }
}

control Verify(inout Headers hdrs, inout Metadata meta) {
    apply {
    }
}

control Compute(inout Headers hdr, inout Metadata meta) {
    apply {
    }
}

V1Switch<Headers, Metadata>(P(), Verify(), Ing(), Eg(), Compute(), DP()) main;

