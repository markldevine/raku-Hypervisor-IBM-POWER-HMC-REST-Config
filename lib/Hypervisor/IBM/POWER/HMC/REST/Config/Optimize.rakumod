use         JSON::Fast;
unit        role Hypervisor::IBM::POWER::HMC::REST::Config::Optimize:api<1>:auth<Mark Devine (mark@markdevine.com)>;

has Bool    $.auto-load = True;

multi trait_mod:<is> (Attribute:D \a, :$conditional-initialization-attribute!) {
    my $mname   = a.name.substr(2);
    my &method  = my method (Str $s?) {
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

method conditional-initialization-attribute-active (Str:D $package!, Str:D $name!) is export {
    return True unless self.config.optimizations.attribute-get_value-profiled;
    return False unless self.config.optimizations.attribute-get_value-is-accessed(:$package, :attribute($name));
    return True;
}


method optimization-init-load {
    self.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
#
#   decide if .init() should proceed to .load()
#
    return self.auto-load;
}

method set-init-load (Bool:D $auto-load) {
    $!auto-load = $auto-load;
}

=finish
