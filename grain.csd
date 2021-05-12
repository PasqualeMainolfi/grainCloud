<CsoundSynthesizer>
<CsOptions>
-o dac ;-i adc
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 1
nchnls = 2
0dbfs = 1


#include "grain_function.udo"

seed(0)

  instr costruttore_sound
if_min, if_max = 1, 3
ia_min, ia_max = .5, .707
ip_min, ip_max = 0, 0
ipan_min, ipan_max = .5, .5
idur_min, idur_max = .01, .01
ir_min, ir_max = .1, .1
idel_min, idel_max = .01, .1

isorgente = open_file("testGrain_3.wav")
; ilive = live_input(44100, 1)

features_sound_granulation("voce1", isorgente, if_min, if_max, ia_min, ia_max, ip_min, ip_max, ipan_min, ipan_max, idur_min, idur_max, ir_min, ir_max, idel_min, idel_max)
  endin

  instr voce1
al, ar sound_granulation p4, p5, p6, p7, p8, p9, p10, p11
outs(al, ar)
  endin


  instr costruttore_sintetici
if_min, if_max = 90, 5000
ia_min, ia_max = .5, .707
ipan_min, ipan_max = 0, 1
idur_min, idur_max = .001, .03
ir_min, ir_max = .01, .03

features_synthetic_granulation("voce2", if_min, if_max, ia_min, ia_max, ipan_min, ipan_max, idur_min, idur_max, ir_min, ir_max)
  endin


  instr voce2
al, ar synthetic_granulation p4, p5, p6, p7
outs(al, ar)
  endin


</CsInstruments>
<CsScore>
i "costruttore_sound" 0 10
; i "costruttore_sintetici" 0 10
</CsScore>
</CsoundSynthesizer>
