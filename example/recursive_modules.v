// CLAUDE GENERATED. MEANT FOR TESTING RECURSION

// recursive_modules.v
// Simulates deep recursive module nesting for Yosys expose testing.
// Each level wraps the level below, passing signals through internal wires.

// ─── Level 0: Base adder ───────────────────────────────────────────────────
module adder_l0 (
    input  [3:0] a,
    input  [3:0] b,
    output [4:0] sum
);
    wire [3:0] internal_xor;
    wire [3:0] internal_carry;

    assign internal_xor   = a ^ b;
    assign internal_carry = a & b;
    assign sum = {1'b0, internal_xor} + {1'b0, internal_carry};
endmodule

// ─── Level 1 ───────────────────────────────────────────────────────────────
module adder_l1 (
    input  [3:0] a,
    input  [3:0] b,
    output [4:0] sum
);
    wire [3:0]  pre_a, pre_b;
    wire [4:0]  sub_sum;
    wire        carry_feedback;

    assign pre_a = a ^ 4'b0001;
    assign pre_b = b ^ 4'b0010;

    adder_l0 u_l0 (
        .a   (pre_a),
        .b   (pre_b),
        .sum (sub_sum)
    );

    assign carry_feedback = sub_sum[4];
    assign sum = sub_sum + {4'b0, carry_feedback};
endmodule

// ─── Level 2 ───────────────────────────────────────────────────────────────
module adder_l2 (
    input  [3:0] a,
    input  [3:0] b,
    output [4:0] sum
);
    wire [3:0] masked_a, masked_b;
    wire [4:0] partial;
    wire [4:0] adjusted;

    assign masked_a = a & 4'hF;
    assign masked_b = b & 4'hF;

    adder_l1 u_l1 (
        .a   (masked_a),
        .b   (masked_b),
        .sum (partial)
    );

    assign adjusted = partial ^ 5'b00011;
    assign sum      = adjusted;
endmodule

// ─── Level 3 ───────────────────────────────────────────────────────────────
module adder_l3 (
    input  [3:0] a,
    input  [3:0] b,
    output [4:0] sum
);
    wire [3:0] a_reg, b_reg;
    wire [4:0] out_a, out_b;
    wire [4:0] combined;

    assign a_reg = a >> 1;
    assign b_reg = b << 1;

    // Instantiate two l2 adders and combine results
    adder_l2 u_l2_a (
        .a   (a),
        .b   (a_reg),
        .sum (out_a)
    );

    adder_l2 u_l2_b (
        .a   (b),
        .b   (b_reg),
        .sum (out_b)
    );

    assign combined = out_a ^ out_b;
    assign sum      = combined;
endmodule

// ─── Level 4 ───────────────────────────────────────────────────────────────
module adder_l4 (
    input  [3:0] a,
    input  [3:0] b,
    output [4:0] sum
);
    wire [3:0] a0, a1, b0, b1;
    wire [4:0] s0, s1, s2;
    wire [3:0] feedback;

    assign a0 = a;
    assign b0 = b;
    assign a1 = a ^ 4'b1010;
    assign b1 = b ^ 4'b0101;

    adder_l3 u_l3_0 (
        .a   (a0),
        .b   (b0),
        .sum (s0)
    );

    adder_l3 u_l3_1 (
        .a   (a1),
        .b   (b1),
        .sum (s1)
    );

    assign feedback = s0[3:0] & s1[3:0];

    adder_l3 u_l3_2 (
        .a   (feedback),
        .b   (a ^ b),
        .sum (s2)
    );

    assign sum = s0 ^ s1 ^ s2;
endmodule

// ─── Level 5 ───────────────────────────────────────────────────────────────
module adder_l5 (
    input  [3:0] a,
    input  [3:0] b,
    output [4:0] sum
);
    wire [4:0] stage0, stage1, stage2, stage3;
    wire [3:0] fb0, fb1;

    adder_l4 u_l4_0 (.a(a),   .b(b),   .sum(stage0));
    adder_l4 u_l4_1 (.a(b),   .b(a),   .sum(stage1));

    assign fb0 = stage0[3:0] ^ stage1[3:0];
    assign fb1 = stage0[3:0] & stage1[3:0];

    adder_l4 u_l4_2 (.a(fb0), .b(fb1), .sum(stage2));
    adder_l4 u_l4_3 (.a(fb1), .b(fb0), .sum(stage3));

    assign sum = stage2 ^ stage3;
endmodule

// ─── Level 6 ───────────────────────────────────────────────────────────────
module adder_l6 (
    input  [7:0] a,
    input  [7:0] b,
    output [8:0] sum
);
    wire [4:0] lo_sum, hi_sum;
    wire [3:0] carry_in;
    wire [4:0] merge;

    adder_l5 u_lo (
        .a   (a[3:0]),
        .b   (b[3:0]),
        .sum (lo_sum)
    );

    adder_l5 u_hi (
        .a   (a[7:4]),
        .b   (b[7:4]),
        .sum (hi_sum)
    );

    assign carry_in = {3'b0, lo_sum[4]};
    assign merge    = hi_sum + {1'b0, carry_in};
    assign sum      = {merge, lo_sum[3:0]};
endmodule

// ─── Level 7: Accumulator with registered feedback ─────────────────────────
module accumulator_l7 (
    input        clk,
    input        rst,
    input  [7:0] a,
    input  [7:0] b,
    output [8:0] acc
);
    reg  [8:0] acc_reg;
    wire [8:0] new_sum;
    wire [7:0] feedback_a;
    wire [7:0] feedback_b;

    assign feedback_a = acc_reg[7:0] ^ a;
    assign feedback_b = acc_reg[7:0] & b;

    adder_l6 u_l6 (
        .a   (feedback_a),
        .b   (feedback_b),
        .sum (new_sum)
    );

    always @(posedge clk or posedge rst) begin
        if (rst)
            acc_reg <= 9'b0;
        else
            acc_reg <= new_sum;
    end

    assign acc = acc_reg;
endmodule

// ─── Level 8: Dual-channel wrapper ─────────────────────────────────────────
module dual_channel_l8 (
    input        clk,
    input        rst,
    input  [7:0] a0, b0,
    input  [7:0] a1, b1,
    output [8:0] acc0,
    output [8:0] acc1,
    output [8:0] combined
);
    wire [8:0] raw0, raw1;
    wire [8:0] cross_a, cross_b;

    accumulator_l7 u_ch0 (
        .clk (clk),
        .rst (rst),
        .a   (a0),
        .b   (b0),
        .acc (raw0)
    );

    accumulator_l7 u_ch1 (
        .clk (clk),
        .rst (rst),
        .a   (a1),
        .b   (b1),
        .acc (raw1)
    );

    assign cross_a = raw0 ^ {1'b0, a1};
    assign cross_b = raw1 ^ {1'b0, b0};

    assign acc0     = raw0;
    assign acc1     = raw1;
    assign combined = cross_a ^ cross_b;
endmodule

// ─── Top: Pipeline of dual channels ────────────────────────────────────────
module top_recursive (
    input        clk,
    input        rst,
    input  [7:0] in_a,
    input  [7:0] in_b,
    output [8:0] result
);
    wire [8:0] stage0_acc0, stage0_acc1, stage0_combined;
    wire [8:0] stage1_acc0, stage1_acc1, stage1_combined;

    // Stage 0
    dual_channel_l8 u_stage0 (
        .clk      (clk),
        .rst      (rst),
        .a0       (in_a),
        .b0       (in_b),
        .a1       (in_b),
        .b1       (in_a),
        .acc0     (stage0_acc0),
        .acc1     (stage0_acc1),
        .combined (stage0_combined)
    );

    // Stage 1 feeds from stage 0 outputs
    dual_channel_l8 u_stage1 (
        .clk      (clk),
        .rst      (rst),
        .a0       (stage0_acc0[7:0]),
        .b0       (stage0_combined[7:0]),
        .a1       (stage0_acc1[7:0]),
        .b1       (stage0_combined[7:0]),
        .acc0     (stage1_acc0),
        .acc1     (stage1_acc1),
        .combined (stage1_combined)
    );

    assign result = stage1_combined ^ stage0_combined;
endmodule