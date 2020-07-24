import cv2
import numpy as np


def isqrt(n):
    x = n
    y = (x + 1) // 2
    while y < x:
        x = y
        y = (x + n // x) // 2
    return x


class PolygonDrawer(object):
    def __init__(self, window_name, img,
                 working_color=(127, 127, 127), final_color=(255, 255, 255)):

        self.window_name = window_name  # Name for our window
        self.img = img
        self.working_color = working_color
        self.final_color = final_color
        self.done = False  # Flag signalling we're done
        self.current = (0, 0)  # Current position, so we can draw the line-in-progress
        self.points = []  # List of points defining our polygon

    def getVertices(self):
        return self.points

    def on_mouse(self, event, x, y, buttons, user_param):
        # Mouse callback that gets called for every mouse event (i.e. moving, clicking, etc.)

        if self.done:  # Nothing more to do
            return

        if event == cv2.EVENT_MOUSEMOVE:
            # We want to be able to draw the line-in-progress, so update current mouse position
            self.current = (x, y)
        elif event == cv2.EVENT_LBUTTONDOWN:
            # Left click means adding a point at current position to the list of points
            print("Adding point #%d with position(%d,%d)" % (len(self.points), x, y))
            self.points.append((x, y))
        elif event == cv2.EVENT_RBUTTONDOWN:
            # Right click means we're done
            print("Completing polygon with %d points." % len(self.points))
            self.done = True

    def run(self):
        # Let's create our working window and set a mouse callback to handle events
        cv2.namedWindow(self.window_name)
        cv2.imshow(self.window_name, np.zeros(self.img.shape, np.uint8))
        cv2.waitKey(1)
        cv2.setMouseCallback(self.window_name, self.on_mouse)

        while not self.done:
            # This is our drawing loop, we just continuously draw new images
            # and show them in the named window
            canvas = self.img.copy()
            if len(self.points) > 0:
                # Draw all the current polygon segments
                cv2.polylines(canvas, np.array([self.points]), False, self.final_color, 1)
                # And  also show what the current segment would look like
                cv2.line(canvas, self.points[-1], self.current, self.working_color)
            # Update the window
            cv2.imshow(self.window_name, canvas)
            # And wait 50ms before next iteration (this will pump window messages meanwhile)
            if cv2.waitKey(50) == 27:  # ESC hit
                self.done = True

        # # User finished entering the polygon points, so let's make the final drawing
        # canvas = frame.copy()
        # # of a filled polygon
        # if (len(self.points) > 0):
        #     cv2.fillPoly(canvas, np.array([self.points]), self.final_color)
        # # And show it
        # cv2.imshow(self.window_name, canvas)
        # # Waiting for the user to press any key
        # cv2.waitKey()
        #
        cv2.destroyWindow(self.window_name)
        return self.getVertices()


class CircleDrawer(PolygonDrawer):

    def getCircle(self):
        arc = self.points[0]
        radius = isqrt((self.points[0][0] - self.points[1][0]) ** 2 + (self.points[0][1] - self.points[1][1]) ** 2)
        return arc, radius

    def run(self, fill=True):
        # Let's create our working window and set a mouse callback to handle events
        cv2.namedWindow(self.window_name)
        cv2.imshow(self.window_name, np.zeros(self.img.shape, np.uint8))
        cv2.waitKey(1)
        cv2.setMouseCallback(self.window_name, self.on_mouse)

        if fill:
            thickness = -1
        else:
            thickness = 1

        while not self.done:
            # This is our drawing loop, we just continuously draw new images
            # and show them in the named window
            canvas = self.img.copy()
            if len(self.points) == 1:
                # Draw all the current polygon segments
                # cv2.polylines(canvas, np.array([self.points]), False, self.final_color, 1)
                cv2.circle(canvas, self.current,
                           isqrt(
                               (self.points[0][0] - self.current[0]) ** 2 + (self.points[0][1] - self.current[1]) ** 2),
                           self.working_color, thickness)
                # And  also show what the current segment would look like
                cv2.line(canvas, self.points[-1], self.current, self.working_color)
            elif len(self.points) == 2:
                cv2.circle(canvas, self.points[1],
                           isqrt((self.points[0][0] - self.points[1][0]) ** 2 + (
                                       self.points[0][1] - self.points[1][1]) ** 2),
                           self.final_color, thickness)
            elif len(self.points) > 2:
                self.points = []
            # Update the window
            cv2.imshow(self.window_name, canvas)
            # And wait 50ms before next iteration (this will pump window messages meanwhile)
            if cv2.waitKey(50) == 27:  # ESC hit
                self.done = True

        cv2.destroyWindow(self.window_name)
        return self.getCircle()


# # ============================================================================
# import pims
#
# folder = 'J:\\Alja Podgornik\\Multimaze arena\\Cohort 1_June 2020\\Week 1\\temp'
# video = pims.Video(folder + '\\try.mp4')
# cd = CircleDrawer('draw a circle bitch', video[0])
# coords = cd.run()
