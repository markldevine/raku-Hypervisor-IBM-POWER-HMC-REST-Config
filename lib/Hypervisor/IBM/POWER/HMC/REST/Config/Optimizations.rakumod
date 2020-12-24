use             JSON::Fast;
unit    module  Hypervisor::IBM::POWER::HMC::REST::Config::Optimizations:ver<0.0.1>:api<1>:auth<Mark Devine (mark@markdevine.com)> is export;

our             %OPTIMIZATION;
                %OPTIMIZATION<ATTRIBUTE><get_value>    = {};
our             $OPTIMIZATION-PATH                     = $*HOME ~ '/dev/' ~ 'OPTIMIZATIONS.json';
our             $OPTIMIZATIONS                         = 0;

constant        OPTIMIZE-ATTRIBUTE-get_value-UPDATED   = 0o0001;
constant        OPTIMIZE-ATTRIBUTE-get_value-PROFILING = 0o0002;
constant        OPTIMIZE-ATTRIBUTE-get_value-PROFILED  = 0o0004;

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

sub conditional-initialization-attribute-active (Str:D $package!, Str:D $name!) is export {
#   (1) no optimization -- return fastest
    return True unless $OPTIMIZATIONS +& OPTIMIZE-ATTRIBUTE-get_value-PROFILED;
#   (2) been profiled, return False as soon as possible
    return False unless %OPTIMIZATION<ATTRIBUTE><get_value>{$package}{$name}:exists;
#   (3) been profiled, and it's an active attribute
    return True;
}

=finish
