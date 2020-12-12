unit    module Hypervisor::IBM::POWER::HMC::REST::Config::END:ver<0.0.1>:api<1>:auth<Mark Devine (mark@markdevine.com)>;

END {
    if %*ENV<PID-PATH>:exists {
        if %*ENV<PID-PATH>.IO.f {
            note .exception.message without %*ENV<PID-PATH>.IO.unlink;
        }
        %*ENV<PID-PATH>:delete;
    }
    if $OPTIMIZATIONS +& OPTIMIZE-ATTRIBUTE-get_value-UPDATED {
        spurt($OPTIMIZATION-PATH, to-json(%OPTIMIZATION));
    }
}

=finish
