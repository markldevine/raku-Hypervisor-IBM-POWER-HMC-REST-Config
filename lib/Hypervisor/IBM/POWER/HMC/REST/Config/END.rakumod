unit    module  Hypervisor::IBM::POWER::HMC::REST::Config::END:ver<0.0.1>:api<1>:auth<Mark Devine (mark@markdevine.com)>;
use             Hypervisor::IBM::POWER::HMC::REST::Config::Optimizations;

END {
    self.config.optimizations.stash-optimizations;
    if %*ENV<PID-PATH>:exists {
        if %*ENV<PID-PATH>.IO.f {
            note .exception.message without %*ENV<PID-PATH>.IO.unlink;
        }
        %*ENV<PID-PATH>:delete;
    }
}

=finish
