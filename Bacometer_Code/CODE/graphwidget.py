# GraphWidget define#

from PyQt5.QtWidgets import *
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
import matplotlib.pyplot as plt
from PyQt5 import QtGui




class GraphWidget(QWidget):

    def __init__(self, parent=None):
        QWidget.__init__(self, parent)

        self.fig = plt.figure()
        self.canvas = self.fig.subplots_adjust(left=0.15)
        self.canvas = FigureCanvas(self.fig)

        layout = QVBoxLayout()
        layout.addWidget(self.canvas)

        self.canvas.axes = self.canvas.figure.add_subplot(111)
        self.setLayout(layout)



