sub viterbi {
    my ($self, $observations) = @_;
    my $states = $self->{states};

    # Initialization
    my $T1 = {};
    my $T2 = {};
    my $first_observation = $observations->[0];

    foreach my $state (@$states) {
        $T1->{$state}[0] = $self->{start}{$state} * $self->get_emission($first_observation, $state);
        $T2->{$state}[0] = undef;
    }

    # Recursion
    for (my $t = 1; $t <= scalar(@$observations); $t++) {
        my $observation = $observations->[$t];

        foreach my $next_state (@$states) {
            my $max_prob      = 0;
            my $argmax        = undef;
            my $emission_prob = $self->get_emission($observation, $next_state);

            foreach my $state (@$states) {
                my $previous_prob   = $T1->{$state}[$t-1];
                my $transition_prob = $self->get_transition($state, $next_state);
                my $candidate_prob  = $previous_prob * $transition_prob * $emission_prob;

                if ($candidate_prob > $max_prob) {
                    $max_prob = $candidate_prob;
                    $argmax   = $state;
                }
            }

            $T1->{$next_state}[$t] = $max_prob;
            $T2->{$next_state}[$t] = $argmax;
        }
    }

    # Termination
    my $last_t     = @$observations;
    my $best_prob  = 0;
    my $best_state = undef;

    foreach my $state (@$states) {
        if ($T1->{$state}[$last_t] > $best_prob) {
            $best_prob  = $T1->{$state}[$last_t];
            $best_state = $state;
        }
    }

    # Backtracking
    my @path;
    $path[$last_t] = $best_state;
    for (my $t = $last_t; $t >= 1; $t--) {
        $path[$t-1] = $T2->{ $path[$t] }[$t];
    }

    return (\@path, $best_prob);
}