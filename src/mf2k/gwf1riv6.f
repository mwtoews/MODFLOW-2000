C     Last change:  ERB  27 Mar 2001   11:47 am
      SUBROUTINE GWF1RIV6AL(ISUM,LCRIVR,MXRIVR,NRIVER,IN,IOUT,IRIVCB,
     1        NRIVVL,IRIVAL,IFREFM,NPRIV,IRIVPB,NNPRIV)
C
C-----VERSION 11JAN2000 GWF1RIV6AL
C     ******************************************************************
C     ALLOCATE ARRAY STORAGE FOR RIVERS
C     ******************************************************************
C
C     SPECIFICATIONS:
C     ------------------------------------------------------------------
      COMMON /RIVCOM/RIVAUX(5)
      CHARACTER*16 RIVAUX
      CHARACTER*200 LINE
C     ------------------------------------------------------------------
C
C1------IDENTIFY PACKAGE AND INITIALIZE NRIVER.
      WRITE(IOUT,1)IN
    1 FORMAT(1X,/1X,'RIV6 -- RIVER PACKAGE, VERSION 6, 1/11/2000',
     1' INPUT READ FROM UNIT',I3)
      NRIVER=0
      NNPRIV=0
C
C2------READ MAXIMUM NUMBER OF RIVER REACHES AND UNIT OR FLAG FOR
C2------CELL-BY-CELL FLOW TERMS.
      CALL URDCOM(IN,IOUT,LINE)
      CALL UPARLSTAL(IN,IOUT,LINE,NPRIV,MXPR)
      IF(IFREFM.EQ.0) THEN
         READ(LINE,'(2I10)') MXACTR,IRIVCB
         LLOC=21
      ELSE
         LLOC=1
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,MXACTR,R,IOUT,IN)
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,IRIVCB,R,IOUT,IN)
      END IF
      WRITE(IOUT,3) MXACTR
    3 FORMAT(1X,'MAXIMUM OF',I5,' ACTIVE RIVER REACHES AT ONE TIME')
      IF(IRIVCB.LT.0) WRITE(IOUT,7)
    7 FORMAT(1X,'CELL-BY-CELL FLOWS WILL BE PRINTED WHEN ICBCFL NOT 0')
      IF(IRIVCB.GT.0) WRITE(IOUT,8) IRIVCB
    8 FORMAT(1X,'CELL-BY-CELL FLOWS WILL BE SAVED ON UNIT',I3)
C
C3------READ AUXILIARY VARIABLES AND CBC ALLOCATION OPTION.
      IRIVAL=0
      NAUX=0
   10 CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,IN)
      IF(LINE(ISTART:ISTOP).EQ.'CBCALLOCATE' .OR.
     1   LINE(ISTART:ISTOP).EQ.'CBC') THEN
         IRIVAL=1
         WRITE(IOUT,11)
   11    FORMAT(1X,'MEMORY IS ALLOCATED FOR CELL-BY-CELL BUDGET TERMS')
         GO TO 10
      ELSE IF(LINE(ISTART:ISTOP).EQ.'AUXILIARY' .OR.
     1        LINE(ISTART:ISTOP).EQ.'AUX') THEN
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,IN)
         IF(NAUX.LT.5) THEN
            NAUX=NAUX+1
            RIVAUX(NAUX)=LINE(ISTART:ISTOP)
            WRITE(IOUT,12) RIVAUX(NAUX)
   12       FORMAT(1X,'AUXILIARY RIVER VARIABLE: ',A)
         END IF
         GO TO 10
      END IF
      NRIVVL=6+NAUX+IRIVAL
C
C4------ALLOCATE SPACE IN THE RX ARRAY FOR THE RIVR ARRAY.
      IRIVPB=MXACTR+1
      MXRIVR=MXACTR+MXPR
      ISOLD=ISUM
      LCRIVR=ISUM
      ISUM=ISUM+NRIVVL*MXRIVR
C
C5------PRINT AMOUNT OF SPACE USED BY RIVER PACKAGE.
      ISP=ISUM-ISOLD
      WRITE (IOUT,14)ISP
   14 FORMAT(1X,I10,' ELEMENTS IN RX ARRAY ARE USED BY RIV')
C
C6------RETURN.
      RETURN
      END
      SUBROUTINE GWF1RIV6RQ(IN,IOUT,NRIVVL,IRIVAL,NCOL,NROW,NLAY,NPRIV,
     1            RIVR,IRIVPB,MXRIVR,IFREFM,ITERP)
C
C-----VERSION 11JAN2000 GWF1RIV6RQ
C     ******************************************************************
C     READ RIVER PARAMETERS
C     ******************************************************************
C
C     SPECIFICATIONS:
C     ------------------------------------------------------------------
      DIMENSION RIVR(NRIVVL,MXRIVR)
      COMMON /RIVCOM/RIVAUX(5)
      CHARACTER*16 RIVAUX
C     ------------------------------------------------------------------
C
C-------READ NAMED PARAMETERS.
      IF(ITERP.EQ.1) WRITE(IOUT,3) NPRIV
    3 FORMAT(1X,//1X,I5,' River parameters')
      IF(NPRIV.GT.0) THEN
         NAUX=NRIVVL-6-IRIVAL
         LSTSUM=IRIVPB
         DO 5 K=1,NPRIV
         LSTBEG=LSTSUM
         CALL UPARLSTRP(LSTSUM,MXRIVR,IN,IOUT,IP,'RIV','RIV',ITERP)
         NLST=LSTSUM-LSTBEG
         CALL ULSTRD(NLST,RIVR,LSTBEG,NRIVVL,MXRIVR,IRIVAL,IN,
     1          IOUT,'REACH NO.  LAYER   ROW   COL'//
     2          '     STAGE    STRESS FACTOR     BOTTOM EL.',
     3          RIVAUX,5,NAUX,IFREFM,NCOL,NROW,NLAY,5,5,ITERP)
    5    CONTINUE
      END IF
C
C6------RETURN
      RETURN
      END
      SUBROUTINE GWF1RIV6RP(RIVR,NRIVER,MXRIVR,IN,IOUT,NRIVVL,IRIVAL,
     1       IFREFM,NCOL,NROW,NLAY,NNPRIV,NPRIV,IRIVPB)
C
C-----VERSION 11JAN2000 GWF1RIV6RP
C     ******************************************************************
C     READ RIVER HEAD, CONDUCTANCE AND BOTTOM ELEVATION
C     ******************************************************************
C
C     SPECIFICATIONS:
C     ------------------------------------------------------------------
      DIMENSION RIVR(NRIVVL,MXRIVR)
      COMMON /RIVCOM/RIVAUX(5)
      CHARACTER*16 RIVAUX
C     ------------------------------------------------------------------
C
C1------READ ITMP (NUMBER OF RIVER REACHES OR FLAG TO REUSE DATA) AND
C1------NUMBER OF PARAMETERS.
      IF(NPRIV.GT.0) THEN
         IF(IFREFM.EQ.0) THEN
            READ(IN,'(2I10)') ITMP,NP
         ELSE
            READ(IN,*) ITMP,NP
         END IF
      ELSE
         NP=0
         IF(IFREFM.EQ.0) THEN
            READ(IN,'(I10)') ITMP
         ELSE
            READ(IN,*) ITMP
         END IF
      END IF
C
C------CALCULATE SOME CONSTANTS
      NAUX=NRIVVL-6-IRIVAL
C
C2------DETERMINE THE NUMBER OF NON-PARAMETER REACHES.
      IF(ITMP.LT.0) THEN
         WRITE(IOUT,7)
    7    FORMAT(1X,/1X,
     1   'REUSING NON-PARAMETER RIVER REACHES FROM LAST STRESS PERIOD')
      ELSE
         NNPRIV=ITMP
      END IF
C
C3------IF THERE ARE NEW NON-PARAMETER REACHES, READ THEM.
      MXACTR=IRIVPB-1
      IF(ITMP.GT.0) THEN
         IF(NNPRIV.GT.MXACTR) THEN
            WRITE(IOUT,99) NNPRIV,MXACTR
   99       FORMAT(1X,/1X,'THE NUMBER OF ACTIVE REACHES (',I4,
     1                     ') IS GREATER THAN MXACTR(',I4,')')
            STOP
         END IF
         CALL ULSTRD(NNPRIV,RIVR,1,NRIVVL,MXRIVR,IRIVAL,IN,
     1          IOUT,'REACH NO.  LAYER   ROW   COL'//
     2          '     STAGE      CONDUCTANCE     BOTTOM EL.',
     3          RIVAUX,5,NAUX,IFREFM,NCOL,NROW,NLAY,5,5,1)
      END IF
      NRIVER=NNPRIV
C
C1C-----IF THERE ARE ACTIVE RIV PARAMETERS, READ THEM AND SUBSTITUTE
      CALL PRESET('RIV')
      IF(NP.GT.0) THEN
         NREAD=NRIVVL-IRIVAL
         DO 30 N=1,NP
         CALL UPARLSTSUB(IN,'RIV',IOUT,'RIV',RIVR,NRIVVL,MXRIVR,NREAD,
     1                MXACTR,NRIVER,5,5,
     2   'REACH NO.  LAYER   ROW   COL'//
     3   '     STAGE      CONDUCTANCE     BOTTOM EL.',RIVAUX,5,NAUX)
   30    CONTINUE
      END IF
C
C3------PRINT NUMBER OF REACHES IN CURRENT STRESS PERIOD.
      WRITE (IOUT,101) NRIVER
  101 FORMAT(1X,/1X,I5,' RIVER REACHES')
C
C8------RETURN.
  260 RETURN
      END
      SUBROUTINE GWF1RIV6FM(NRIVER,MXRIVR,RIVR,HNEW,HCOF,RHS,IBOUND,
     1                  NCOL,NROW,NLAY,NRIVVL)
C
C-----VERSION 11JAN2000 GWF1RIV6FM
C     ******************************************************************
C     ADD RIVER TERMS TO RHS AND HCOF
C     ******************************************************************
C
C     SPECIFICATIONS:
C     ------------------------------------------------------------------
      DOUBLE PRECISION HNEW,RRBOT
      DIMENSION RIVR(NRIVVL,MXRIVR),HNEW(NCOL,NROW,NLAY),
     1          HCOF(NCOL,NROW,NLAY),RHS(NCOL,NROW,NLAY),
     2          IBOUND(NCOL,NROW,NLAY)
C     ------------------------------------------------------------------
C
C
C1------IF NRIVER<=0 THERE ARE NO RIVERS. RETURN.
      IF(NRIVER.LE.0)RETURN
C
C2------PROCESS EACH CELL IN THE RIVER LIST.
      DO 100 L=1,NRIVER
C
C3------GET COLUMN, ROW, AND LAYER OF CELL CONTAINING REACH.
      IL=RIVR(1,L)
      IR=RIVR(2,L)
      IC=RIVR(3,L)
C
C4------IF THE CELL IS EXTERNAL SKIP IT.
      IF(IBOUND(IC,IR,IL).LE.0)GO TO 100
C
C5------SINCE THE CELL IS INTERNAL GET THE RIVER DATA.
      HRIV=RIVR(4,L)
      CRIV=RIVR(5,L)
      RBOT=RIVR(6,L)
      RRBOT=RBOT
C
C6------COMPARE AQUIFER HEAD TO BOTTOM OF STREAM BED.
      IF(HNEW(IC,IR,IL).LE.RRBOT)GO TO 96
C
C7------SINCE HEAD>BOTTOM ADD TERMS TO RHS AND HCOF.
      RHS(IC,IR,IL)=RHS(IC,IR,IL)-CRIV*HRIV
      HCOF(IC,IR,IL)=HCOF(IC,IR,IL)-CRIV
      GO TO 100
C
C8------SINCE HEAD<BOTTOM ADD TERM ONLY TO RHS.
   96 RHS(IC,IR,IL)=RHS(IC,IR,IL)-CRIV*(HRIV-RBOT)
  100 CONTINUE
C
C9------RETURN
      RETURN
      END
      SUBROUTINE GWF1RIV6BD(NRIVER,MXRIVR,RIVR,IBOUND,HNEW,
     1      NCOL,NROW,NLAY,DELT,VBVL,VBNM,MSUM,KSTP,KPER,IRIVCB,
     2      ICBCFL,BUFF,IOUT,PERTIM,TOTIM,NRIVVL,IRIVAL,IAUXSV)
C-----VERSION 05JUNE2000 GWF1RIV6BD
C     ******************************************************************
C     CALCULATE VOLUMETRIC BUDGET FOR RIVERS
C     ******************************************************************
C
C     SPECIFICATIONS:
C     ------------------------------------------------------------------
      COMMON /RIVCOM/RIVAUX(5)
      CHARACTER*16 RIVAUX
      CHARACTER*16 VBNM(MSUM),TEXT
      DOUBLE PRECISION HNEW,HHNEW,CHRIV,RRBOT,CCRIV,RATIN,RATOUT,RRATE
      DIMENSION RIVR(NRIVVL,MXRIVR),IBOUND(NCOL,NROW,NLAY),
     1          HNEW(NCOL,NROW,NLAY),VBVL(4,MSUM),BUFF(NCOL,NROW,NLAY)
C
      DATA TEXT /'   RIVER LEAKAGE'/
C     ------------------------------------------------------------------
C
C1------INITIALIZE CELL-BY-CELL FLOW TERM FLAG (IBD) AND
C1------ACCUMULATORS (RATIN AND RATOUT).
      ZERO=0.
      RATIN=ZERO
      RATOUT=ZERO
      IBD=0
      IF(IRIVCB.LT.0 .AND. ICBCFL.NE.0) IBD=-1
      IF(IRIVCB.GT.0) IBD=ICBCFL
      IBDLBL=0
C
C2------IF CELL-BY-CELL FLOWS WILL BE SAVED AS A LIST, WRITE HEADER.
      IF(IBD.EQ.2) THEN
         NAUX=NRIVVL-6-IRIVAL
         IF(IAUXSV.EQ.0) NAUX=0
         CALL UBDSV4(KSTP,KPER,TEXT,NAUX,RIVAUX,IRIVCB,NCOL,NROW,NLAY,
     1          NRIVER,IOUT,DELT,PERTIM,TOTIM,IBOUND)
      END IF
C
C3------CLEAR THE BUFFER.
      DO 50 IL=1,NLAY
      DO 50 IR=1,NROW
      DO 50 IC=1,NCOL
      BUFF(IC,IR,IL)=ZERO
50    CONTINUE
C
C4------IF NO REACHES, SKIP FLOW CALCULATIONS.
      IF(NRIVER.EQ.0)GO TO 200
C
C5------LOOP THROUGH EACH RIVER REACH CALCULATING FLOW.
      DO 100 L=1,NRIVER
C
C5A-----GET LAYER, ROW & COLUMN OF CELL CONTAINING REACH.
      IL=RIVR(1,L)
      IR=RIVR(2,L)
      IC=RIVR(3,L)
      RATE=ZERO
C
C5B-----IF CELL IS NO-FLOW OR CONSTANT-HEAD MOVE ON TO NEXT REACH.
      IF(IBOUND(IC,IR,IL).LE.0)GO TO 99
C
C5C-----GET RIVER PARAMETERS FROM RIVER LIST.
      HRIV=RIVR(4,L)
      CRIV=RIVR(5,L)
      RBOT=RIVR(6,L)
      RRBOT=RBOT
      HHNEW=HNEW(IC,IR,IL)
C
C5D-----COMPARE HEAD IN AQUIFER TO BOTTOM OF RIVERBED.
      IF(HHNEW.GT.RRBOT) THEN
C
C5E-----AQUIFER HEAD > BOTTOM THEN RATE=CRIV*(HRIV-HNEW).
         CCRIV=CRIV
         CHRIV=CRIV*HRIV
         RRATE=CHRIV - CCRIV*HHNEW
         RATE=RRATE
C
C5F-----AQUIFER HEAD < BOTTOM THEN RATE=CRIV*(HRIV-RBOT).
      ELSE
         RATE=CRIV*(HRIV-RBOT)
         RRATE=RATE
      END IF
C
C5G-----PRINT THE INDIVIDUAL RATES IF REQUESTED(IRIVCB<0).
      IF(IBD.LT.0) THEN
         IF(IBDLBL.EQ.0) WRITE(IOUT,61) TEXT,KPER,KSTP
   61    FORMAT(1X,/1X,A,'   PERIOD',I3,'   STEP',I3)
         WRITE(IOUT,62) L,IL,IR,IC,RATE
   62    FORMAT(1X,'REACH',I4,'   LAYER',I3,'   ROW',I4,'   COL',I4,
     1       '   RATE',1PG15.6)
         IBDLBL=1
      END IF
C
C5H------ADD RATE TO BUFFER.
      BUFF(IC,IR,IL)=BUFF(IC,IR,IL)+RATE
C
C5I-----SEE IF FLOW IS INTO AQUIFER OR INTO RIVER.
      IF(RATE)94,99,96
C
C5J-----AQUIFER IS DISCHARGING TO RIVER SUBTRACT RATE FROM RATOUT.
   94 RATOUT=RATOUT-RRATE
      GO TO 99
C
C5K-----AQUIFER IS RECHARGED FROM RIVER; ADD RATE TO RATIN.
   96 RATIN=RATIN+RRATE
C
C5L-----IF SAVING CELL-BY-CELL FLOWS IN LIST, WRITE FLOW.  OR IF
C5L-----RETURNING THE FLOW IN THE RIVR ARRAY, COPY FLOW TO RIVR.
   99 IF(IBD.EQ.2) CALL UBDSVB(IRIVCB,NCOL,NROW,IC,IR,IL,RATE,
     1                  RIVR(1,L),NRIVVL,NAUX,7,IBOUND,NLAY)
      IF(IRIVAL.NE.0) RIVR(NRIVVL,L)=RATE
  100 CONTINUE
C
C6------IF CELL-BY-CELL FLOW WILL BE SAVED AS A 3-D ARRAY,
C6------CALL UBUDSV TO SAVE THEM.
      IF(IBD.EQ.1) CALL UBUDSV(KSTP,KPER,TEXT,IRIVCB,BUFF,NCOL,NROW,
     1                          NLAY,IOUT)
C
C7------MOVE RATES,VOLUMES & LABELS INTO ARRAYS FOR PRINTING.
  200 RIN=RATIN
      ROUT=RATOUT
      VBVL(3,MSUM)=RIN
      VBVL(4,MSUM)=ROUT
      VBVL(1,MSUM)=VBVL(1,MSUM)+RIN*DELT
      VBVL(2,MSUM)=VBVL(2,MSUM)+ROUT*DELT
      VBNM(MSUM)=TEXT
C
C8------INCREMENT BUDGET TERM COUNTER.
      MSUM=MSUM+1
C
C9------RETURN.
      RETURN
      END