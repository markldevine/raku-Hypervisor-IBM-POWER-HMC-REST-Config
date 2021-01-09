unit    role Hypervisor::IBM::POWER::HMC::REST::Config::Optimize:api<1>:auth<Mark Devine (mark@markdevine.com)>;

method attribute-is-accessed (Str:D $package, Str:D $name?) {
    return True unless self.config.optimizations.attribute-get_value-profiled;
    if $name {
        return False unless self.config.optimizations.attribute-get_value-is-accessed(:$package, :attribute($name));
    }
    else {
        return False unless self.config.optimizations.attribute-package-is-accessed(:$package);
    }
    return True;
}

=finish
