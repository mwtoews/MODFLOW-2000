      SUBROUTINE DRN1AL(ISUM,LENX,LCDRAI,NDRAIN,MXDRN,IN,IOUT,
     1                           IDRNCB)
C
C-----VERSION 1604 12MAY1987 DRN1AL
C     ******************************************************************
C     ALLOCATE ARRAY STORAGE FOR DRAIN PACKAGE
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
C     ------------------------------------------------------------------
C
C1------IDENTIFY PACKAGE AND INITIALIZE NDRAIN.
      WRITE(IOUT,1)IN
    1 FORMAT(1H0,'DRN1 -- DRAIN PACKAGE, VERSION 1, 9/1/87',
     1' INPUT READ FROM UNIT',I3)
      NDRAIN=0
C
C2------READ & PRINT MXDRN & IDRNCB(UNIT & FLAG FOR CELL-BY-CELL FLOW)
      READ(IN,2) MXDRN,IDRNCB
    2 FORMAT(2I10)
      WRITE(IOUT,3) MXDRN
    3 FORMAT(1H ,'MAXIMUM OF',I5,' DRAINS')
      IF(IDRNCB.GT.0) WRITE(IOUT,9) IDRNCB
    9 FORMAT(1X,'CELL-BY-CELL FLOWS WILL BE RECORDED ON UNIT',I3)
      IF(IDRNCB.LT.0) WRITE(IOUT,8)
    8 FORMAT(1X,'CELL-BY-CELL FLOWS WILL BE PRINTED WHEN ICBCFL NOT 0')
C
C3------SET LCDRAI EQUAL TO ADDRESS OF FIRST UNUSED SPACE IN X.
      LCDRAI=ISUM
C
C4------CALCULATE AMOUNT OF SPACE USED BY THE DRAIN PACKAGE.
      ISP=5*MXDRN
      ISUM=ISUM+ISP
C
C5------PRINT AMOUNT OF SPACE USED BY DRAIN PACKAGE.
      WRITE(IOUT,4) ISP
    4 FORMAT(1X,I8,' ELEMENTS IN X ARRAY ARE USED FOR DRAINS')
      ISUM1=ISUM-1
      WRITE(IOUT,5) ISUM1,LENX
    5 FORMAT(1X,I8,' ELEMENTS OF X ARRAY USED OUT OF',I8)
      IF(ISUM1.GT.LENX) WRITE(IOUT,6)
    6 FORMAT(1X,'   ***X ARRAY MUST BE DIMENSIONED LARGER***')
C
C6------RETURN
      RETURN
      END
      SUBROUTINE DRN1RP(DRAI,NDRAIN,MXDRN,IN,IOUT)
C
C
C-----VERSION 1603 25APR1983 DRN1RP
C     ******************************************************************
C     READ DRAIN LOCATIONS, ELEVATIONS, AND CONDUCTANCES
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      DIMENSION DRAI(5,MXDRN)
C     ------------------------------------------------------------------
C
C1------READ ITMP(NUMBER OF DRAIN CELLS OR FLAG TO REUSE DATA)
      READ(IN,8) ITMP
    8 FORMAT(I10)
C
C2------TEST ITMP
      IF(ITMP.GE.0) GO TO 50
C
C2A-----IF ITMP<0 THEN REUSE DATA FROM LAST STRESS PERIOD.
      WRITE(IOUT,7)
    7 FORMAT(1H0,'REUSING DRAINS FROM LAST STRESS PERIOD')
      RETURN
C
C3------IF ITMP=>0 THEN IT IS THE NUMBER OF DRAINS.
   50 NDRAIN=ITMP
      IF(NDRAIN.LE.MXDRN) GO TO 100
C
C4------IF NDRAIN>MXDRN THEN STOP
      WRITE(IOUT,99) NDRAIN,MXDRN
   99 FORMAT(1H0,'NDRAIN(',I4,') IS GREATER THAN MXDRN(',I4,')')
      STOP
C
C5------PRINT NUMBER OF DRAINS IN THIS STRESS PERIOD.
  100 WRITE(IOUT,1) NDRAIN
    1 FORMAT(1H0,//1X,I5,' DRAINS')
C
C6------IF THERE ARE NO DRAINS THEN RETURN.
      IF(NDRAIN.EQ.0) GO TO 260
C
C7------READ AND PRINT DATA FOR EACH DRAIN.
      WRITE(IOUT,3)
    3 FORMAT(1H0,15X,'LAYER',5X,'ROW',5X
     1,'COL   ELEVATION   CONDUCTANCE   DRAIN NO.'/1X,15X,60('-'))
      DO 250 II=1,NDRAIN
      READ (IN,4) K,I,J,DRAI(4,II),DRAI(5,II)
    4 FORMAT(3I10,2F10.0)
      WRITE (IOUT,5) K,I,J,DRAI(4,II),DRAI(5,II),II
    5 FORMAT(1X,15X,I4,I9,I8,G13.4,G14.4,I8)
      DRAI(1,II)=K
      DRAI(2,II)=I
      DRAI(3,II)=J
  250 CONTINUE
C
C8------RETURN
  260 RETURN
C
      END
      SUBROUTINE DRN1FM(NDRAIN,MXDRN,DRAI,HNEW,HCOF,RHS,IBOUND,
     1              NCOL,NROW,NLAY)
C
C-----VERSION 1030 10APR1985 DRN1FM
C
C     ******************************************************************
C     ADD DRAIN FLOW TO SOURCE TERM
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      DOUBLE PRECISION HNEW
C
      DIMENSION DRAI(5,MXDRN),HNEW(NCOL,NROW,NLAY),
     1         RHS(NCOL,NROW,NLAY),IBOUND(NCOL,NROW,NLAY),
     1         HCOF(NCOL,NROW,NLAY)
C     ------------------------------------------------------------------
C
C1------IF NDRAIN<=0 THERE ARE NO DRAINS. RETURN
      IF(NDRAIN.LE.0) RETURN
C
C2------PROCESS EACH CELL IN THE DRAIN LIST
      DO 100 L=1,NDRAIN
C
C3------GET COLUMN, ROW AND LAYER OF CELL CONTAINING DRAIN.
      IL=DRAI(1,L)
      IR=DRAI(2,L)
      IC=DRAI(3,L)
C
C4-------IF THE CELL IS EXTERNAL SKIP IT.
      IF(IBOUND(IC,IR,IL).LE.0) GO TO 100
C
C5-------IF THE CELL IS INTERNAL GET THE DRAIN DATA.
      EL=DRAI(4,L)
      HHNEW=HNEW(IC,IR,IL)
C
C6------IF HEAD IS LOWER THAN DRAIN THEN SKIP THIS CELL.
      IF(HHNEW.LE.EL) GO TO 100
C
C7------HEAD IS HIGHER THAN DRAIN. ADD TERMS TO RHS AND HCOF.
      C=DRAI(5,L)
      HCOF(IC,IR,IL)=HCOF(IC,IR,IL)-C
      RHS(IC,IR,IL)=RHS(IC,IR,IL)-C*EL
  100 CONTINUE
C
C8------RETURN
      RETURN
      END
      SUBROUTINE DRN1BD(NDRAIN,MXDRN,VBNM,VBVL,MSUM,DRAI,DELT,HNEW,
     1        NCOL,NROW,NLAY,IBOUND,KSTP,KPER,IDRNCB,ICBCFL,BUFF,IOUT)
C
C-----VERSION 1338 22AUG1987 DRN1BD
C
C     ******************************************************************
C     CALCULATE VOLUMETRIC BUDGET FOR DRAINS
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*4 VBNM,TEXT
      DOUBLE PRECISION HNEW
C
      DIMENSION VBNM(4,MSUM),VBVL(4,MSUM),DRAI(5,MXDRN),
     1           HNEW(NCOL,NROW,NLAY),IBOUND(NCOL,NROW,NLAY),
     2           BUFF(NCOL,NROW,NLAY)
      DIMENSION TEXT(4)
C
      DATA TEXT(1),TEXT(2),TEXT(3),TEXT(4) /'    ','    ','  DR','AINS'/
C     ------------------------------------------------------------------
C
C1------INITIALIZE CELL-BY-CELL FLOW TERM FLAG (IBD) AND
C1------ACCUMULATORS (RATIN AND RATOUT).
      RATOUT=0.
      IBD=0
C
C2------IF THERE ARE NO DRAINS THEN DO NOT ACCUMULATE DRAIN FLOW
      IF(NDRAIN.LE.0) GO TO 200
C
C3------TEST TO SEE IF CELL-BY-CELL FLOW TERMS ARE NEEDED.
      IF(ICBCFL.EQ.0 .OR. IDRNCB.LE.0) GO TO 60
C
C3B-----CELL-BY-CELL FLOW TERMS ARE NEEDED SET IBD AND CLEAR BUFFER.
      IBD=1
      DO 50 IL=1,NLAY
      DO 50 IR=1,NROW
      DO 50 IC=1,NCOL
      BUFF(IC,IR,IL)=0.
   50 CONTINUE
C
C4------FOR EACH DRAIN ACCUMULATE DRAIN FLOW
   60 DO 100 L=1,NDRAIN
C
C5------GET LAYER, ROW & COLUMN OF CELL CONTAINING REACH.
      IL=DRAI(1,L)
      IR=DRAI(2,L)
      IC=DRAI(3,L)
C
C6------IF CELL IS EXTERNAL IGNORE IT.
      IF(IBOUND(IC,IR,IL).LE.0) GO TO 100
C
C7------GET DRAIN PARAMETERS FROM DRAIN LIST.
      EL=DRAI(4,L)
      C=DRAI(5,L)
      HHNEW=HNEW(IC,IR,IL)
C
C8------IF HEAD LOWER THAN DRAIN THEN FORGET THIS CELL.
      IF(HHNEW.LE.EL) GO TO 100
C
C9------HEAD HIGHER THAN DRAIN.  CALCULATE Q=C*(EL-HHNEW).
C9------SUBTRACT Q FROM RATOUT.
      Q=C*(EL-HHNEW)
      RATOUT=RATOUT-Q
C
C10-----PRINT THE INDIVIDUAL RATES IF REQUESTED(IDRNCB<0).
      IF(IDRNCB.LT.0.AND.ICBCFL.NE.0) WRITE(IOUT,900) (TEXT(N),N=1,4),
     1    KPER,KSTP,L,IL,IR,IC,Q
  900 FORMAT(1H0,4A4,'   PERIOD',I3,'   STEP',I3,'   DRAIN',I4,
     1    '   LAYER',I3,'   ROW',I4,'   COL',I4,'   RATE',G15.7)
C
C11-----IF C-B-C FLOW TERMS ARE TO BE SAVED THEN ADD Q TO BUFFER.
      IF(IBD.EQ.1) BUFF(IC,IR,IL)=BUFF(IC,IR,IL)+Q
  100 CONTINUE
C
C12-----IF C-B-C FLOW TERMS WILL BE SAVED CALL UBUDSV TO RECORD THEM.
      IF(IBD.EQ.1) CALL UBUDSV(KSTP,KPER,TEXT,IDRNCB,BUFF,NCOL,NROW,
     1                          NLAY,IOUT)
C
C13-----MOVE RATES,VOLUMES & LABELS INTO ARRAYS FOR PRINTING.
  200 VBVL(3,MSUM)=0.
      VBVL(4,MSUM)=RATOUT
      VBVL(2,MSUM)=VBVL(2,MSUM)+RATOUT*DELT
      VBNM(1,MSUM)=TEXT(1)
      VBNM(2,MSUM)=TEXT(2)
      VBNM(3,MSUM)=TEXT(3)
      VBNM(4,MSUM)=TEXT(4)
C
C14-----INCREMENT BUDGET TERM COUNTER
      MSUM=MSUM+1
C
C15-----RETURN
      RETURN
      END
