opcode map, i, iiiii
    iin, iout_min, iout_max, iin_min, iin_max xin
    iy = ((iin - iin_min) * (iout_max - iout_min))/(iin_max - iin_min) + iout_min
xout(iy)
endop

opcode map_k, k, kkkkk
    kin, kout_min, kout_max, kin_min, kin_max xin
    ky = ((kin - kin_min) * (kout_max - kout_min))/(kin_max - kin_min) + kout_min
xout(ky)
endop

opcode w_hann, k, ki
    kx, ilen xin
    i2pi = 2 * $M_PI
    kw = 0.5 * (1 - cos((i2pi * kx)/(ilen - 1)))
xout(kw)
endop

opcode w_coseno, k, ki
    kx, ilen xin
    ipi = $M_PI
    kw = cos(((ipi * kx)/(ilen - 1)) - (ipi/2))
xout(kw)
endop

opcode w_blackman_harris, k, ki
    kx, ilen xin

    i2pi = 2 * $M_PI
    ia0, ia1, ia2, ia3 = 0.35875, 0.48829, 0.141128, 0.01168
    kw = ia0 - ia1 * cos(i2pi * kx/(ilen - 1)) + ia2 * cos(2 * i2pi * kx/(ilen - 1)) - ia3 * cos(3 * i2pi * kx/(ilen - 1))
xout(kw)
endop


opcode open_file, i, S
    Sfile xin
    ifile = ftgen(0, 0, 0, 1, Sfile, 0, 0, 0)
xout(ifile)
endop

opcode live_input, i, ii
    ibuffer, ichn xin
    setksmps(1)
    ilive = ftgen(0, 0, ibuffer, 2, 0)
    ain = inch(ichn)
    ki init 0
    if(ki < ibuffer) then
        tablew(ain, a(ki), ilive)
        ki += 1
        ki = ki%ibuffer
    endif
xout(ilive)
endop


// funzioni per la generazione ---> sound granulation
opcode features_sound_granulation, 0, Siiiiiiiiiiiiiiii
    Sinstr, ifile, if_min, if_max, ia_min, ia_max, ip_min, ip_max, ipan_min, ipan_max, idur_min, idur_max, ihop_min, ihop_max, idel_min, idel_max, imode_value xin
    ilen = ftlen(ifile)
    ihop init 0 // inizializzazione per OLA

    aggiorna:
        // attributi grano
        ifreq = random(if_min, if_max)
        iamp = random(ia_min, ia_max)
        iphase = random(ip_min, ip_max)
        ipan = random(ipan_min, ipan_max)
        idel = random(idel_min, idel_max)

        // durata del grano
        idur_grano = random(idur_min, idur_max)
        idur_to_sample = ceil(sr * idur_grano)
        idur_to_time = idur_to_sample/sr

        // grain delay
        ir_grain = random(ihop_min, ihop_max)
        ir_to_sample = ceil(sr * ir_grain)
        ir_to_time = ir_to_sample/sr

        if(imode_value == 0) then
            ii, ij, ik = ifreq, ifreq, 1/ifreq
        elseif(imode_value == 1) then
            ii, ij, ik = 1, ifreq, 1/ifreq
        endif

        // informazioni per modulo finestra e calcolo punto di fase
        idurata_totale = ilen/sr // durata totale sound file
        idurata_totale_to_time = idurata_totale * ik
        idurata_totale_to_sample = ceil(idurata_totale_to_time * sr)
        idurata_totale_to_time = idurata_totale_to_sample/sr

        // mappatura fase
        iphase_w = map(iphase, 0, idur_to_sample, 0, 1)
        iphase_tab = map(iphase, 0, idurata_totale_to_sample, 0, 1)

            timout(0, idel, to_granula)
            reinit aggiorna

    to_granula:
    schedule(Sinstr, 0, idur_to_time, iamp, ipan, iphase_w, iphase_tab, idur_to_sample, ii, ij, ihop, ifile)
    ihop += ir_to_sample
    ihop = ihop%idurata_totale_to_sample
    rireturn
endop


opcode sound_granulation, aa, iiiiiiiii
    ip4, ip5, ip6, ip7, ip8, ip9, ip10, ip11, ip12 xin
    setksmps(1)

    ki init 0
    if(ki < ip8) then
        kndx = abs(ip6 - ki) * ip9
        koverlapp = abs(ip7 - ip11) * ip10
        ainv = w_hann(ki, ip8)
        agrano = p4 * ainv * tablei:a(kndx + koverlapp, ip12)
        aleft = (agrano * sqrt(ip5))/2
        aright = (agrano * sqrt(1 - ip5))/2
        ki += 1
    endif

xout(aleft, aright)
endop


// grani sintetici
opcode features_synthetic_granulation, 0, Siiiiiiiiii
    Sinstr, if_min, if_max, ia_min, ia_max, ipan_min, ipan_max, idur_min, idur_max, ihop_min, ihop_max xin

    aggiorna:
        // attributi grano
        ifreq = random(if_min, if_max)
        iamp = random(ia_min, ia_max)
        ipan = random(ipan_min, ipan_max)

        // durata del grano
        idur_grano = random(idur_min, idur_max)
        idur_to_sample = ceil(sr * idur_grano)
        idur_to_time = idur_to_sample/sr

        // grain delay
        ir_grain = random(ihop_min, ihop_max)
        ir_to_sample = ceil(sr * ir_grain)
        ir_to_time = ir_to_sample/sr

            timout(0, ir_to_time, to_granula)
            reinit aggiorna

    to_granula:
    schedule(Sinstr, 0, idur_to_time, ifreq, iamp, ipan, idur_to_sample)
    rireturn
endop


opcode synthetic_granulation, aa, iiii
    ip4, ip5, ip6, ip7 xin
    setksmps(1)

    i2pi = 2 * $M_PI

    ki init 0
    if(ki < ip7) then
        ainv = w_hann(ki, ip7)
        agrano = ip5 * ainv * sin(i2pi * ip4/sr * ki)
        aleft = (agrano * sqrt(ip6))/2
        aright = (agrano * sqrt(1 - ip6))/2
        ki += 1
    endif

xout(aleft, aright)
endop
