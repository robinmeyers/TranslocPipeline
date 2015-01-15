use strict;
use warnings;



# sub filter_unjoined ($$) {
#   my $tlxls = shift;
#   my $brksite = shift;

#   my $filter;

#   my $junctions = 0;

#   return 0 unless defined $tlxls->[0]->{R1_ID};

#   if (@$tlxls < 2) {
#     $filter = "Unjoined";
#   } else {

#     foreach my $tlxl (@$tlxls[1..$#{$tlxls}]) {
#       last if $tlxl->{Rname} eq "Adapter";
#       next if defined $tlxl->{R1_Rgap} && $tlxl->{R1_Rgap} >= 0 && $tlxl->{R1_Rgap} < 3;
#       next if defined $tlxl->{R2_Rgap} && $tlxl->{R2_Rgap} >= 0 && $tlxl->{R2_Rgap} < 3;
#       $junctions++;
#     }

#     $filter = "Unjoined" unless $junctions;

#     if ($brksite->{aln_strand} == 1) {
#       $filter = "Unjoined" if $tlxls->[1]->{tlx}->{B_Rend} > $brksite->{joining_threshold};
#     } else {
#       $filter = "Unjoined" if $tlxls->[1]->{tlx}->{B_Rstart} < $brksite->{joining_threshold};
#     }
#   }

#   $junctions = 0;

#   foreach my $tlxl (@$tlxls) {
#     if (defined $tlxl->{tlx} && ! defined $tlxl->{tlx}->{Filter}) {
#       if (defined $filter) {
#         $tlxl->{tlx}->{Filter} = $filter;
#       } else {
#         $junctions++;
#       }
#     }
#   }

#   return $junctions;

# }


# sub filter_mapping_quality ($$$$$$$$$$){

#   my $tlxls_ref = shift;
#   my $R1_alns_ref = shift;
#   my $R2_alns_ref = shift;
#   my $ol_thresh = shift;
#   my $mismatch_thresh_int = shift;
#   my $mismatch_thresh_coef = shift;
#   my $max_frag_length = shift;
#   my $match_award = shift;
#   my $mismatch_penalty = shift;
#   my $mapqfh = shift;

#   my @tlxls = @$tlxls_ref;
#   my @R1_alns = @$R1_alns_ref;
#   my @R2_alns = @$R2_alns_ref;


#   my $filter;

#   my $quality_maps = 0;

#   return 0 unless defined $tlxls[0]->{R1_ID};


#   TLXL: foreach my $tlxl (@tlxls) {
#     if (defined $filter) {
#       $tlxl->{tlx}->{Filter} = $filter if defined $tlxl->{tlx} && ! defined $tlxl->{tlx}->{Filter};
#       next TLXL;
#     }
#     last TLXL if $tlxl->{Rname} eq "Adapter";
#     my @R1_OL;
#     my @R2_OL;
#     if (defined $tlxl->{R1_ID}) {
#       my $tlxl_R1_length = $tlxl->{R1_Qend} - $tlxl->{R1_Qstart} + 1;
#       my $tlxl_R1_score = $tlxl->{R1_AS};
#       my $score_difference_thresh = ($match_award + $mismatch_penalty) * 
#                                     ($mismatch_thresh_int + $mismatch_thresh_coef * $tlxl_R1_length);
#       # print(join("\t",$tlxl_R1_length,$tlxl_R1_score,$score_difference_thresh)."\n");
#       foreach my $R1_aln (@R1_alns) {
#         next unless defined $R1_aln->{ID} && $R1_aln->{ID} ne $tlxl->{R1_ID};
#         next if $tlxl->{Rname} eq "Breaksite" && $R1_aln->{Rname} eq "Breaksite";
#         my $overlap = min($tlxl->{R1_Qend},$R1_aln->{Qend}) - max($tlxl->{R1_Qstart},$R1_aln->{Qstart}) + 1;
#         my $length = $R1_aln->{Qend} - $R1_aln->{Qstart} + 1;
#         my $score = $R1_aln->{AS};

#         if ($overlap >= $ol_thresh * ($tlxl->{R1_Qend} - $tlxl->{R1_Qstart} + 1) 
#               && $score >= $tlxl_R1_score - $score_difference_thresh) {
#           push (@R1_OL,$R1_aln);
#         }
#       }
#     }

#     if (defined $tlxl->{R2_ID}) {
#       my $tlxl_R2_length = $tlxl->{R2_Qend} - $tlxl->{R2_Qstart} + 1;
#       my $tlxl_R2_score = $tlxl->{R2_AS};
#       my $score_difference_thresh = ($match_award + $mismatch_penalty) * 
#                                     ($mismatch_thresh_int + $mismatch_thresh_coef * $tlxl_R2_length);
#       foreach my $R2_aln (@R2_alns) {
#         next unless defined $R2_aln->{ID} && $R2_aln->{ID} ne $tlxl->{R2_ID};
#         next if $tlxl->{Rname} eq "Breaksite" && $R2_aln->{Rname} eq "Breaksite";
#         my $overlap = min($tlxl->{R2_Qend},$R2_aln->{Qend}) - max($tlxl->{R2_Qstart},$R2_aln->{Qstart}) + 1;
#         my $length = $R2_aln->{Qend} - $R2_aln->{Qstart} + 1;
#         my $score = $R2_aln->{AS};


#         if ($overlap >= $ol_thresh * ($tlxl->{R2_Qend} - $tlxl->{R2_Qstart} + 1) 
#               && $score >= $tlxl_R2_score - $score_difference_thresh) {
#           push (@R2_OL,$R2_aln);
#         }
#       }
#     }

#     if (defined $tlxl->{R1_ID} && $tlxl->{R2_ID}) {
#       ALN_PAIR: foreach my $R1_aln (@R1_OL) {
#         foreach my $R2_aln (@R2_OL) {
#           if (pair_is_proper($R1_aln,$R2_aln,$max_frag_length)) {
#             $filter = "MappingQuality";
#             $mapqfh->print(join("\t",$tlxl->{Qname},
#                                      $tlxl->{Rname},
#                                      $tlxl->{R1_Rstart},
#                                      $tlxl->{R1_Rend},
#                                      $tlxl->{Strand},
#                                      $tlxl->{R1_Qstart},
#                                      $tlxl->{R1_Qend},
#                                      $tlxl->{R1_AS},
#                                      $tlxl->{R1_Cigar},
#                                      $tlxl->{Rname},
#                                      $tlxl->{R2_Rstart},
#                                      $tlxl->{R2_Rend},
#                                      $tlxl->{Strand},
#                                      $tlxl->{R2_Qstart},
#                                      $tlxl->{R2_Qend},
#                                      $tlxl->{R2_AS},
#                                      $tlxl->{R2_Cigar})."\n");
#             $mapqfh->print(join("\t",$R1_aln->{Qname},
#                                      $R1_aln->{Rname},
#                                      $R1_aln->{Rstart},
#                                      $R1_aln->{Rend},
#                                      $R1_aln->{Strand},
#                                      $R1_aln->{Qstart},
#                                      $R1_aln->{Qend},
#                                      $R1_aln->{AS},
#                                      $R1_aln->{Cigar},
#                                      $R2_aln->{Rname},
#                                      $R2_aln->{Rstart},
#                                      $R2_aln->{Rend},
#                                      $R2_aln->{Strand},
#                                      $R2_aln->{Qstart},
#                                      $R2_aln->{Qend},
#                                      $R2_aln->{AS},
#                                      $R2_aln->{Cigar})."\n");
#             last ALN_PAIR;
#           }
#         }
#       }
#     } else {
#       if (scalar @R1_OL > 0 || scalar @R2_OL > 0) {
#         $filter = "MappingQuality";
#         if (scalar @R1_OL > 0) {
#           $mapqfh->print(join("\t",$tlxl->{Qname},
#                                        $tlxl->{Rname},
#                                        $tlxl->{R1_Rstart},
#                                        $tlxl->{R1_Rend},
#                                        $tlxl->{Strand},
#                                        $tlxl->{R1_Qstart},
#                                        $tlxl->{R1_Qend},
#                                        $tlxl->{R1_AS},
#                                        $tlxl->{R1_Cigar})."\n");
#           foreach my $aln (@R1_OL) {
#             $mapqfh->print(join("\t", $aln->{Qname},
#                                       $aln->{Rname},
#                                       $aln->{Rstart},
#                                       $aln->{Rend},
#                                       $aln->{Strand},
#                                       $aln->{Qstart},
#                                       $aln->{Qend},
#                                       $aln->{AS},
#                                       $aln->{Cigar})."\n");
#           }
#         } else {
#           $mapqfh->print(join("\t",$tlxl->{Qname},
#                                        "",
#                                        "",
#                                        "",
#                                        "",
#                                        "",
#                                        "",
#                                        "",
#                                        "",
#                                        $tlxl->{Rname},
#                                        $tlxl->{R2_Rstart},
#                                        $tlxl->{R2_Rend},
#                                        $tlxl->{Strand},
#                                        $tlxl->{R2_Qstart},
#                                        $tlxl->{R2_Qend},
#                                        $tlxl->{R2_AS},
#                                        $tlxl->{R2_Cigar})."\n");
#           foreach my $aln (@R2_OL) {
#             $mapqfh->print(join("\t", $aln->{Qname},
#                                       "",
#                                       "",
#                                       "",
#                                       "",
#                                       "",
#                                       "",
#                                       "",
#                                       "",
#                                       $aln->{Rname},
#                                       $aln->{Rstart},
#                                       $aln->{Rend},
#                                       $aln->{Strand},
#                                       $aln->{Qstart},
#                                       $aln->{Qend},
#                                       $aln->{AS},
#                                       $aln->{Cigar})."\n");
#           }
#         }
#       }
#     }

#     if (defined $tlxl->{tlx} && ! defined $tlxl->{tlx}->{Filter}) {
#       if (defined $filter) {
#         $tlxl->{tlx}->{Filter} = $filter;
#       } else {
#         $quality_maps++;
#       }
#     }
#   }

#   return $quality_maps;

# }


# sub filter_mispriming ($$) {
#   my $tlxls = shift;
#   my $brksite = shift;

#   my $filter;
#   my $priming = 0;

#   return 0 unless defined $tlxls->[0]->{R1_ID};

#   $filter = "Mispriming" if $brksite->{aln_strand} == 1 && $tlxls->[0]->{R1_Rend} < $brksite->{priming_threshold};
#   $filter = "Mispriming" if $brksite->{aln_strand} == -1 && $tlxls->[0]->{R1_Rstart} > $brksite->{priming_threshold};

#   foreach my $tlxl (@$tlxls) {
#     if (defined $tlxl->{tlx} && ! defined $tlxl->{tlx}->{Filter}) {
#       if (defined $filter) {
#         $tlxl->{tlx}->{Filter} = $filter;
#       } else {
#         $priming++;
#       }
#     }
#   }

#   return $priming;

# }

# sub filter_freq_cutter ($$) {
#   my $tlxls = shift;
#   my $cutter = shift;

#   my $filter;

#   my $no_cutter = 0;

#   return 0 unless defined $tlxls->[0]->{R1_ID};

#   foreach my $tlxl (@$tlxls) {
#     if (defined $tlxl->{tlx} && ! defined $tlxl->{tlx}->{Filter}) {
#       if (defined $filter) {
#         $tlxl->{tlx}->{Filter} = $filter;
#         next;
#       }


#       if (defined $cutter && $cutter->seq =~ /\S/) {
#         if (uc($tlxl->{tlx}->{J_Seq}) =~ $cutter->seq || substr($tlxl->{tlx}->{Seq},0,$tlxl->{tlx}->{Qstart}+4) =~ $cutter->seq) {
#           $filter = "FreqCutter";
#           $tlxl->{tlx}->{Filter} = $filter;
#           next;
#         }
#       }

#       $no_cutter++;
#     }
#   }

#   return $no_cutter;
# }

# sub filter_breaksite ($) {
#   my $tlxls = shift;

#   my $filter;

#   my $outside_breaksite = 0;

#   return 0 unless defined $tlxls->[0]->{R1_ID};
#   return 0 unless defined $tlxls->[1];

#   foreach my $i (0..$#{$tlxls}) {

#     my $tlxl = $tlxls->[$i];

#     if (defined $tlxl->{tlx} && ! defined $tlxl->{tlx}->{Filter}) {
#       if (defined $filter) {
#         $tlxl->{tlx}->{Filter} = $filter;
#         next;
#       }



#       if (($i = 1 && $tlxl->{tlx}->{Rname} eq "Breaksite") ||
#           ($i = 1 && defined $tlxl->{R1_Rgap} && $tlxl->{R1_Rgap} >=0 && $tlxl->{R1_Rgap} < 10) ||
#           ($i = 1 && defined $tlxl->{R2_Rgap} && $tlxl->{R2_Rgap} >=0 && $tlxl->{R2_Rgap} < 10)) {
#         $filter = "Breaksite";
#         $tlxl->{tlx}->{Filter} = $filter;
#         next;
#       }

#       $outside_breaksite++;
#     }
#   }

#   return $outside_breaksite;
# }

# sub filter_sequential_junctions ($) {
#   my $tlxls = shift;

#   my $filter;

#   my $primary_junction = 0;

#   return 0 unless defined $tlxls->[0]->{R1_ID};

#   foreach my $tlxl (@$tlxls) {

#     if (defined $tlxl->{tlx} && ! defined $tlxl->{tlx}->{Filter}) {
#       if (defined $filter) {
#         $tlxl->{tlx}->{Filter} = $filter;
#         next;
#       }

#       $primary_junction++;
#       $filter = "SequentialJunction";


#     }
#   }

#   return $primary_junction;



# }

sub is_a_junction ($) {
  my $tlx = shift;
  if (! defined $tlx->{Rname} || $tlx->{Rname} eq "" || $tlx->{Rname} eq "Adapter") {
    return(0);
  } else {
    return(1);
  }
}

sub filter_entire_read ($$) {
  my $tlxs = shift;
  my $filter = shift;

  my $junctions = 0;
  foreach my $tlx (@$tlxs) {
    $tlx->{filters}->{$filter} = 1;
    $junctions++ if is_a_junction($tlx);
  }
  return($junctions);
}

sub filter_remainder_of_read ($$$) {
  my $tlxs = shift;
  my $filter = shift;
  my $i = shift;

  my $junctions = 0;

  foreach my $tlx (@$tlxs[$i..$#$tlxs]) {
    $tlx->{filters}->{$filter} = 1;
    $junctions++ if is_a_junction($tlx);
  }


}

sub filter_unaligned ($$) {
  my $read_obj = shift;
  my $params = shift;

  my $tlxs = $read_obj->{tlxs};

  if (! defined $tlxs->[0]->{B_Rname}) {
    my $junctions = filter_entire_read($tlxs,"unaligned");
    return(1,$junctions);
  } else {
    return(0,0);
  }

}


sub filter_baitonly ($$) {
  my $read_obj = shift;
  my $params = shift;

  my $tlxs = $read_obj->{tlxs};

  if (defined $tlxs->[0]->{B_Rname} && ! is_a_junction($tlxs->[0])) {
    my $junctions = filter_entire_read($tlxs,"baitonly");
    return(1,$junctions)
  } else {
    return(0,0);
  }
}


sub filter_uncut ($$) {
  my $read_obj = shift;
  my $params = shift;

  my $tlxs = $read_obj->{tlxs};
  my $tlx = $tlxs->[0];

  if (defined $tlx->{B_Rname}) {
    if ($tlx->{B_Strand} == 1) {
      if ($tlx->{B_Rend} > $params->{brksite}->{uncut_threshold}) {
        my $junctions = filter_entire_read($tlxs,"uncut");
        return(1,$junctions);
      }
    } else {
      if ($tlx->{B_Rstart} < $params->{brksite}->{uncut_threshold}) {
        my $junctions = filter_entire_read($tlxs,"uncut");
        return(1,$junctions);
      }
    }
  }

  return(0,0);
}

sub filter_misprimed ($$) {
  my $read_obj = shift;
  my $params = shift;

  my $tlxs = $read_obj->{tlxs};
  my $tlx = $tlxs->[0];

  if (defined $tlx->{B_Strand}) {
    if ($tlx->{B_Strand} == 1) {
      if ($tlx->{B_Rend} < $params->{brksite}->{misprimed_threshold}) {
        my $junctions = filter_entire_read($tlxs,"misprimed");
        return(1,$junctions);
      }
    } else {
      if ($tlx->{B_Rstart} > $params->{brksite}->{misprimed_threshold}) {
        my $junctions = filter_entire_read($tlxs,"misprimed");
        return(1,$junctions);
      }
    }
  }

  return(0,0);
}


sub filter_freqcut ($$) {
  my $read_obj = shift;
  my $params = shift;

  my $tlxs = $read_obj->{tlxs};

  my $i = 0;

  if ($params->{cutter} =~ /\S/) {
    foreach my $tlx (@$tlxs) {
      if (uc($tlx->{J_Seq}) =~ $params->{cutter} ||
          uc(substr($tlx->{Seq},0,$tlx->{Qstart}+4)) =~ $params->{cutter}) {
        my $junctions = filter_remainder_of_read($tlx,"freqcut",$i);
        return($i == 0 ? 1 : 0, $junctions);
      }
      $i++;
    }
  }

  return(0,0);
}

sub filter_largegap ($$) {
  my $read_obj = shift;
  my $params = shift;

  my $tlxs = $read_obj->{tlxs};

  my $i = 0;


  foreach my $tlx (@$tlxs) {
    if (defined $tlx->{Qstart} && defined $tlx->{B_Qend} &&
        $tlx->{Qstart} - $tlx->{B_Qend} > $params->{max_largegap}) {
      my $junctions = filter_remainder_of_read($tlxs,"largegap",$i);
      return($i == 0 ? 1 : 0, $junctions);
    }
    $i++;
  }

  return(0,0);
}

# sub filter_repeatseq ($$) {
#   my $read_obj = shift;
# }

sub calc_sum_base_Q ($) {
  my $aln = shift;
  
  my $sum = 0;

  my @qual;
  my @cigar;

  

  return($sum);

}

sub check_overlap ($$$;$$) {
  my $ol_thresh;
  my $base_aln_1 = shift;
  my $aln_1 = shift;
  my $base_aln_2 = shift;
  my $aln_2 = shift;

  my $base_length = 0;
  my $check_length = 0;



  if (defined $base_aln_2) {

  }

  if ($check_length/$base_length > $main::params->{}) {
    return(1);
  } else {
    return(0);
  }

}

sub filter_mapqual ($$) {
  my $read_obj = shift;
  my $params = shift;

  my $tlxs = $read_obj->{tlxs};

  my $R1_alns = $read_obj->{R1_alns};
  my $R2_alns = $read_obj->{R2_alns};

  my $i = 0;
  foreach my $tlx (@$tlxs) {
    next unless is_a_junction($tlx);

    my $tlx_R1_aln = $R1_alns->{$tlx->{R1_ID}} if defined $tlx->{R1_ID};
    my $tlx_R2_aln = $R2_alns->{$tlx->{R2_ID}} if defined $tlx->{R2_ID};

    my $tlx_sum_base_Q = calc_sum_base_Q($tlx_R1_aln,$tlx_R2_aln);
    my $tlx_aln_length = $tlx_R1_aln->{Qend} - $tlx_R1_aln->{Qstart} +
                         $tlx_R2_aln->{Qend} - $tlx_R2_aln->{Qend};

    my @competing_sum_base_Q;

    if (defined $tlx_R1_aln && defined $tlx_R2_aln) {
      # only consider paired alignments
      foreach my $R1_aln_ID (keys $R1_alns) {
        foreach my $R2_aln_ID (keys $R2_alns) {
          next if $R1_aln_ID eq $tlx->{R1_ID} && $R2_aln_ID eq $tlx->{R2_ID};
          my $R1_aln = $R1_alns->{$R1_aln_ID};
          my $R2_aln = $R2_alns->{$R2_aln_ID};
          next unless pair_is_proper($R1_aln,$R2_aln,$params->{max_frag_len});
          next unless check_overlap($main::params->{mapq_ol_thresh},
                                    $tlx_R1_aln,$R1_aln,$tlx_R2_aln,$R2_aln);

          my $aln_length = $R1_aln->{Qend} - $R1_aln->{Qstart} +
                           $R2_aln->{Qend} - $R2_aln->{Qend};
          my $len_scale_factor = $tlx_aln_length/$aln_length;

          push(@competing_sum_base_Q,$len_scale_factor*(calc_sum_base_Q($R1_aln) +
                                                        calc_sum_base_Q($R2_aln)));
        }



      }


    } elsif (defined $tlx_R1_aln) {
      # only consider R1 alignments

    } else {
      # only consider R2 alignments

    }

    my $tlx_p = 10 ** (-$tlx_sum_base_Q/10);
    my $competing_p = sum(map { 10 ** (-$_/10) } @competing_sum_base_Q);

    my $map_qual_score = -10 * log10(1 - ($tlx_p/$competing_p));

    $i++;
  }


  #   my $R1_aln = ;
  #   my $R2_aln;


  #   print "TLX $i\n";
  #   if (defined $tlx->{B_R1_ID}) {
  #     print "B R1 " . $R1_alns->{$tlx->{B_R1_ID}}->{Rname} . "\n";
  #   }
  #   if (defined $tlx->{B_R2_ID}) {
  #     print "B R2 " . $R2_alns->{$tlx->{B_R2_ID}}->{Rname} . "\n";
  #   }
  #   if (defined $tlx->{R1_ID}) {
  #     print "R1 " . $R1_alns->{$tlx->{R1_ID}}->{Rname} . "\n";
  #   }
  #   if (defined $tlx->{R2_ID}) {
  #     print "R2 " . $R2_alns->{$tlx->{R2_ID}}->{Rname} . "\n";
  #   }
  #   $i++;
  # }

#   my $tlxls = $read_obj->{tlxls};

#   # Filter here
#   # my $mapqual = first prey ? 1 : 0;

#   return($mapqual,$n_juncs);
  return(0,0);
}

sub filter_breaksite ($$) {
  my $read_obj = shift;
  my $params = shift;

  my $tlxs = $read_obj->{tlxs};
  my $i = 0;
  foreach my $tlx (@$tlxs) {
    if (defined $tlx->{Rname} && $tlx->{Rname} eq "Breaksite") {
      my $junctions = filter_remainder_of_read($tlxs,"breaksite",$i);
      return($i == 0 ? 1 : 0, $junctions);
    }
    $i++;
  }
  return(0,0);
}

sub filter_sequential ($$) {
  my $read_obj = shift;
  my $params = shift;

  my $tlxs = $read_obj->{tlxs};

  if (defined $tlxs->[1] && is_a_junction($tlxs->[1])) {
    my $junctions = filter_remainder_of_read($tlxs,"sequential",1);
    return(0,$junctions);
  }

  return(0,0);

}


1;