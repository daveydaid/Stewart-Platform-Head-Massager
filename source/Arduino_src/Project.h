/**************************************************************************
 * FILE NAME: Project.h                                                   *
 * DESCRIPTION: Contains all #defines for the pin config of Mega2560 and  *
 *              some hard defines for the AX-12A servos                   *
 *                                                                        *
 * VERSION: 1 (02/03/2022)                                                *
 *************************************************************************/

#ifndef PROJECT_h
#define PROJECT_h

#define MOTOR_DIRECTION_PIN  10
#define SERVO_CONNECT_CONFIRM_PIN  13

#define MIN_ANGLE         0
#define MIN_ANGLE_VALUE   0
#define MAX_ANGLE         300
#define MAX_ANGLE_VALUE   1023

#define MAX_RPM           59    // Datasheet: No Load Speed 59 [rev/min] (at 12V)
#define MAX_SPEED_SET     530   // Datasheet: Resolution is 0.111 * MAX_RPM

#endif // PROJECT_h
