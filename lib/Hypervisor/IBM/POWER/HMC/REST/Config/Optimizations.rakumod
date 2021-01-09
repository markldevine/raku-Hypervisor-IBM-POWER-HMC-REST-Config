use         JSON::Fast;
unit class  Hypervisor::IBM::POWER::HMC::REST::Config::Optimizations:ver<0.0.1>:api<1>:auth<Mark Devine (mark@markdevine.com)>;

has         $.active;
has         %.map;
has         $.optimize                              = False;
has         $.optimizations-path is required;

constant    OPTIMIZE-ATTRIBUTE-get_value-UPDATED   = 0o0001;
constant    OPTIMIZE-ATTRIBUTE-get_value-PROFILING = 0o0002;
constant    OPTIMIZE-ATTRIBUTE-get_value-PROFILED  = 0o0004;

submethod TWEAK {
    $!active = 0;

note '$!optimize = ' ~ $!optimize;

    if $!optimize {
        if $!optimizations-path.IO.e {
            note .exception.message without $!optimizations-path.IO.unlink;
        }
#   Optimization: *
#   ...
#   Optimization: Attribute get_value actual usage
        $!active +&= +^OPTIMIZE-ATTRIBUTE-get_value-PROFILED;
        $!active +|= OPTIMIZE-ATTRIBUTE-get_value-PROFILING;
note '$!active = ' ~ $!active;
    }
    else {
        if self!retrieve {
#   Optimization: *
#   ...
#   Optimization: Attribute get_value actual usage
            if %!map<ATTRIBUTE><get_value>.elems {
                $!active +|= OPTIMIZE-ATTRIBUTE-get_value-PROFILED;
                $!active +&= +^OPTIMIZE-ATTRIBUTE-get_value-PROFILING;
note '$!active = ' ~ $!active;
            }
            else {
                if $!optimizations-path.IO.e {
                    note .exception.message without $!optimizations-path.IO.unlink;
                }
                $!active +&= +^OPTIMIZE-ATTRIBUTE-get_value-PROFILED;
                $!active +&= +^OPTIMIZE-ATTRIBUTE-get_value-PROFILING;
note '$!active = ' ~ $!active;
            }
        }
        else {
#   Optimization: *
#   ...
#   Optimization: Attribute get_value actual usage
            $!active +&= +^OPTIMIZE-ATTRIBUTE-get_value-PROFILED;
            $!active +&= +^OPTIMIZE-ATTRIBUTE-get_value-PROFILING;
note '$!active = ' ~ $!active;
        }
    }
}

method attribute-get_value-set-as-accessed (Str:D :$package, Str:D :$attribute) {   note 'attribute-get_value-set-as-accessed';
    %!map<ATTRIBUTE><get_value>{$package}{$attribute} = 1;
    $!active +|= OPTIMIZE-ATTRIBUTE-get_value-UPDATED;
}

method attribute-get_value-is-accessed (Str:D :$package, Str:D :$attribute) {       note 'attribute-get_value-is-accessed';
    return True if %!map<ATTRIBUTE><get_value>{$package}{$attribute}:exists;
    return False;
}

method attribute-get_value-profiled () {                                            note 'attribute-get_value-profiled';
    return True if $!active +& OPTIMIZE-ATTRIBUTE-get_value-PROFILED;
    return False;
}

method attribute-get_value-profiling () {                                           note 'attribute-get_value-profiling';
    return True if $!active +& OPTIMIZE-ATTRIBUTE-get_value-PROFILING;
    return False;
}

method !retrieve () {
    if $!optimizations-path.IO.f && ! $!optimizations-path.IO.z {
        given $!optimizations-path.IO.open {
            .lock: :shared;
            %!map = from-json(.slurp);
            .close;
        }
    }
    %!map.elems;
}

method stash () {
note "\n\n STASH \n\n";
dd %!map;
    if $!optimize && %!map.elems {
        given $!optimizations-path.IO.open(:w) {
            .lock;
            .spurt: to-json(%!map);
            .close;
        }
    }
}

method flush () {
    $!optimizations-path.IO.unlink;
}

method init-load () {
    True;
}

=finish
