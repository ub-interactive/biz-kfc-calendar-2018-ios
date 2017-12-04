//=============================================================================================================================
//
// Copyright (c) 2015-2017 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
// EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
// and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
//
//=============================================================================================================================

#import "ArCore.h"

#import <easyar/camera.oc.h>
#import <easyar/frame.oc.h>
#import <easyar/framestreamer.oc.h>
#import <easyar/imagetracker.oc.h>
#import <easyar/imagetarget.oc.h>
#import <easyar/renderer.oc.h>
#import <easyar/vector.oc.h>

#include <OpenGLES/ES2/gl.h>

#import "KFCConfig.h"

easyar_CameraDevice *camera = nil;
easyar_CameraFrameStreamer *streamer = nil;
NSMutableArray<easyar_ImageTracker *> *trackers = nil;
easyar_Renderer *videobg_renderer = nil;

int tracked_target = 0;
int active_target = 0;

bool viewport_changed = false;
int view_size[] = {0, 0};
int view_rotation = 0;
int viewport[] = {0, 0, 1280, 720};

void loadAllFromJsonFile(easyar_ImageTracker *tracker, NSString *path) {
    for (easyar_ImageTarget *target in [easyar_ImageTarget setupAll:path storageType:easyar_StorageType_Assets]) {
        [tracker loadTarget:target callback:^(easyar_Target *target, bool status) {
            NSLog(@"loaded target (%d): %@ (%d)", status, [target name], [target runtimeID]);
        }];
    }
}

BOOL initialize() {
    camera = [easyar_CameraDevice create];
    streamer = [easyar_CameraFrameStreamer create];
    [streamer attachCamera:camera];

    bool status = true;
    status &= [camera open:easyar_CameraDeviceType_Default];
    [camera setSize:[easyar_Vec2I create:@[@1280, @720]]];

    if (!status) {return status;}
    easyar_ImageTracker *tracker = [easyar_ImageTracker create];
    [tracker attachStreamer:streamer];
    loadAllFromJsonFile(tracker, @"targets.json");
    trackers = [[NSMutableArray<easyar_ImageTracker *> alloc] init];
    [trackers addObject:tracker];

    return status;
}

void finalize() {
    tracked_target = 0;
    active_target = 0;

    [trackers removeAllObjects];
    videobg_renderer = nil;
    streamer = nil;
    camera = nil;
}

BOOL startCamera() {
    bool status = true;
    status &= (camera != nil) && [camera start];
    status &= (streamer != nil) && [streamer start];
    [camera setFocusMode:easyar_CameraDeviceFocusMode_Continousauto];
    return status;
}

BOOL stopCamera() {
    bool status = true;
    status &= (streamer != nil) && [streamer stop];
    status &= (camera != nil) && [camera stop];
    return status;
}

BOOL stopTracker() {
    bool status = true;
    for (easyar_ImageTracker *tracker in trackers) {
        status &= [tracker stop];
    }
    return status;
}

BOOL startTracker() {
    bool status = true;
    for (easyar_ImageTracker *tracker in trackers) {
        status &= [tracker start];
    }
    return status;
}

void initGL() {
    if (active_target != 0) {
        tracked_target = 0;
        active_target = 0;
    }
    videobg_renderer = nil;
    videobg_renderer = [easyar_Renderer create];
}

void resizeGL(int width, int height) {
    view_size[0] = width;
    view_size[1] = height;
    viewport_changed = true;
}

void updateViewport() {
    easyar_CameraCalibration *calib = camera != nil ? [camera cameraCalibration] : nil;
    int rotation = calib != nil ? [calib rotation] : 0;
    if (rotation != view_rotation) {
        view_rotation = rotation;
        viewport_changed = true;
    }
    if (viewport_changed) {
        int size[] = {1, 1};
        if (camera && [camera isOpened]) {
            size[0] = [[camera size].data[0] intValue];
            size[1] = [[camera size].data[1] intValue];
        }
        if (rotation == 90 || rotation == 270) {
            int t = size[0];
            size[0] = size[1];
            size[1] = t;
        }
        float scaleRatio = MAX((float) view_size[0] / (float) size[0], (float) view_size[1] / (float) size[1]);
        int viewport_size[] = {(int) roundf(size[0] * scaleRatio), (int) roundf(size[1] * scaleRatio)};
        int viewport_new[] = {(view_size[0] - viewport_size[0]) / 2, (view_size[1] - viewport_size[1]) / 2, viewport_size[0], viewport_size[1]};
        memcpy(&viewport[0], &viewport_new[0], 4 * sizeof(int));

        if (camera && [camera isOpened])
            viewport_changed = false;
    }
}

void render() {
    glClearColor(1.f, 1.f, 1.f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    if (videobg_renderer != nil) {
        int default_viewport[] = {0, 0, view_size[0], view_size[1]};
        easyar_Vec4I *oc_default_viewport = [easyar_Vec4I create:@[@(default_viewport[0]), @(default_viewport[1]), @(default_viewport[2]), @(default_viewport[3])]];
        glViewport(default_viewport[0], default_viewport[1], default_viewport[2], default_viewport[3]);
        if ([videobg_renderer renderErrorMessage:oc_default_viewport]) {
            return;
        }
    }

    if (streamer == nil) {return;}
    easyar_Frame *frame = [streamer peek];
    updateViewport();
    glViewport(viewport[0], viewport[1], viewport[2], viewport[3]);

    if (videobg_renderer != nil) {
        [videobg_renderer render:frame viewport:[easyar_Vec4I create:@[@(viewport[0]), @(viewport[1]), @(viewport[2]), @(viewport[3])]]];
    }

    NSArray<easyar_TargetInstance *> *targetInstances = [frame targetInstances];
    if ([targetInstances count] > 0) {
        easyar_TargetInstance *targetInstance = targetInstances[0];
        easyar_Target *target = [targetInstance target];
        int status = [targetInstance status];
        if (status == easyar_TargetStatus_Tracked) {
            int runtimeID = [target runtimeID];
            if (active_target != 0 && active_target != runtimeID) {
                tracked_target = 0;
                active_target = 0;
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:KFC_NOTIFICATION_NAME_AR_SCAN_SUCCEED object:[target name]];
        }
    } else {
        if (tracked_target != 0) {
            tracked_target = 0;
        }
    }
}
