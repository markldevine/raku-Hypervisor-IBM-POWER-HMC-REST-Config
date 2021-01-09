unit    role Hypervisor::IBM::POWER::HMC::REST::Config::Optimize:api<1>:auth<Mark Devine (mark@markdevine.com)>;

method conditional-initialization-attribute-active (Str:D $package!, Str:D $name!) is export {
    return True unless self.config.optimizations.attribute-get_value-profiled;
    return False unless self.config.optimizations.attribute-get_value-is-accessed(:$package, :attribute($name));
    return True;
}

=finish
