unit module Hypervisor::IBM::POWER::HMC::REST::Config::Traits:api<1>:auth<Mark Devine (mark@markdevine.com)>;

multi trait_mod:<is> (Attribute:D \a, :$conditional-initialization-attribute!) is export {
    my $mname   = a.name.substr(2);
    my &method  = my method (Str $s?) {
note 'Here';
        if $s {
            a.set_value(self, $s);
            return $s;
        }
        if self.config.optimizations.attribute-get_value-profiled {
            unless self.config.optimizations.attribute-get_value-is-accessed(:package(self.^name), :attribute(a.name.substr(2))) {
                self.config.optimizations.flush;
                die 'The optimization map is stale and has been deleted. Restart and optionally re-optimize. Exiting...';
            }
        }
        elsif self.config.optimizations.attribute-get_value-profiling {
            self.config.optimizations.attribute-get_value-set-as-accessed(:package(self.^name), :attribute(a.name.substr(2)))
        }
        return a.get_value(self);
    }
    &method.set_name($mname);
    a.package.^add_method($mname, &method);
}

=finish
