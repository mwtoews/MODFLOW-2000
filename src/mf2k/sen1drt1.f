C     Last change:  ERB  23 Jun 2000   11:40 am
      SUBROUTINE SEN1DRT1FM(MXDRT,DRTF,HNEW,NCOL,NROW,NLAY,IBOUND,RHS,
     &                      IP,NDRTVL,IDRTFL)
C-----VERSION 20000619 ERB
C     ******************************************************************
C     FOR DRAIN-RETURN AND RECIPIENT CELLS: CALCULATE MATRIX AND VECTOR
C     DERIVATIVES, MULTIPLY BY HEADS, AND ADD COMPONENTS TO RHS.
C     ******************************************************************
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      REAL DRTF, RHS
      INTEGER I, IBOUND, II, J, K, MXDRT, NCOL, NLAY, NROW
      DOUBLE PRECISION DF, HH, HNEW(NCOL,NROW,NLAY)
      DIMENSION DRTF(NDRTVL,MXDRT), IBOUND(NCOL,NROW,NLAY),
     &          RHS(NCOL,NROW,NLAY)
      INCLUDE 'param.inc'
C     ------------------------------------------------------------------
C
      IF (IACTIVE(IP).EQ.0) RETURN
      IPOS1 = IPLOC(1,IP)
      NPC = IPLOC(2,IP)-IPOS1+1
C-----LOOP THROUGH PARAMETER CELLS
      DO 20 II = 1, NPC
        ICP = IPOS1-1+II
        K = DRTF(1,ICP)
        I = DRTF(2,ICP)
        J = DRTF(3,ICP)
        IF (IBOUND(J,I,K).GT.0) THEN
C---------CALCULATE CONTRIBUTION TO SENSITIVITY
          ELEVD = DRTF(4,ICP)
          HH = HNEW(J,I,K)
          IF (HH.GT.ELEVD) THEN
            FACTOR = DRTF(5,ICP)
            DF = FACTOR*(ELEVD-HH)
            RHS(J,I,K) = RHS(J,I,K) - DF
C  CALCULATE CONTRIBUTION TO SENSITIVITY OF RETURN FLOW
            IF (IDRTFL.GT.0) THEN
              KR = DRTF(6,ICP)
              IF (KR.NE.0) THEN
                IR = DRTF(7,ICP)
                JR = DRTF(8,ICP)
                RFPROP = DRTF(9,ICP)
                DFR = RFPROP*FACTOR*(HH-ELEVD)
                RHS(JR,IR,KR) = RHS(JR,IR,KR) - DFR
              ENDIF
            ENDIF
          ENDIF
        ENDIF
   20 CONTINUE
C
      RETURN
      END