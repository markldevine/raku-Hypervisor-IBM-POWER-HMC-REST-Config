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
        return a.get_value(self) unless $OPTIMIZATIONS & (OPTIMIZE-ATTRIBUTE-get_value-PROFILING +| OPTIMIZE-ATTRIBUTE-get_value-PROFILED);
        if $OPTIMIZATIONS +& OPTIMIZE-ATTRIBUTE-get_value-PROFILED {
            unless %OPTIMIZATION<ATTRIBUTE><get_value>{self.^name}{a.name.substr(2)}:exists {
                $OPTIMIZATION-PATH.IO.unlink;
                die 'Optimization map is stale (deleted...) -- restart and optionally re-optimize. Exiting...';
            }
        }
        elsif $OPTIMIZATIONS +& OPTIMIZE-ATTRIBUTE-get_value-PROFILING {
            %OPTIMIZATION<ATTRIBUTE><get_value>{self.^name}{a.name.substr(2)} = 1;
            $OPTIMIZATIONS +|= OPTIMIZE-ATTRIBUTE-get_value-UPDATED;
        }
        return a.get_value(self);
    }
    &method.set_name($mname);
    a.package.^add_method($mname, &method);
}

method conditional-initialization-attribute-active (Str:D $package!, Str:D $name!) is export {
    return True unless $OPTIMIZATIONS +& OPTIMIZE-ATTRIBUTE-get_value-PROFILED;
    return False unless %OPTIMIZATION<ATTRIBUTE><get_value>{$package}{$name}:exists;
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
