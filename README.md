# Summary of Code

## Purpose & Application to Project

The purpose of this code was to quantify and analyze the error in focus pattern introduced
by the constraint of only binary phase (0 deg. or 180 deg.) being available to each reflecting
element on the RIS, relative to the ideal case of continuous phase available to each
reflecting element on the RIS.

First, we wanted to be able to see the focus pattern that would be produced by the 18x
rectangular RIS assuming we had full, continuous control over the phase introduced to the
reflected wave at each element. Then we wanted to see the focus pattern produced by a
phase mask limited to only 0 deg. or 180 deg. at each element.

Finally, we wanted to see the difference between the two plots in order to visualize the
quantization error.

Being able to visualize and quantify the error will inform how to potentially modify the
receiving array and/or the RIS phase in order to maximize power transfer efficiency between
transmitter and receiver given the binary phase constraint.

## Functionality

To this end, we wrote a collection of .m files that allow a user to specify operational details
such as:

- Transmitter frequency
- Transmitter EIRP
- Transmitter location relative to RIS panel
- Dimension of RIS (element x element)
- Location of desired focal point relative to RIS panel

and, depending on the config file ran, will either compute the required continuous phase
distribution to achieve the desired focus, or compute the best approximation to the ideal
distribution given the binary phase constraint.

Each config file (“config_CONT.m” and “config_BIN.m”) will then automatically calculate
the reflected field at a given distance from the RIS (defaulting to the distance at which the


desired focal point rests, but specifiable to be any distance desired) over a 2 meter by 2
meter grid and plot the result as a heat map.

If the user wants, they can suppress the reflection output and only view the phase mask
itself by commenting out the reflection plotting call and changing a parameter value to
select to plot the phase mask.

**config_CONT.m, config_BIN.m**

These files are where the user changes desired specifications such as focal point,
transmitter location, etc. Then when run, the script calls the appropriate “get_phases()”
function (either “get_phases_bin()” or “get_phases_v3()” depending on whether it is
“config_BIN.m” or “config_CONT.m”), calculates the appropriate phase mask, stores it in a
matrix, and passes that matrix along with the other relevant parameters to “plot_E_field()”,
which plots the reflected wave at some distance from the RIS (defaulted to distance at
desired focal point).

**get_phases_v3.m, get_phases_bin.m**

These files calculate the necessary phase delay at each element on the RIS in order to
achieve the desired focus given a certain location of the transmitter. First, it constructs a
matrix of element locations, assuming a Cartesian coordinate system in which the RIS is
centered about the origin in the XY-plane, with the positive z-axis emerging normal to the
RIS from its centerpoint.

It then converts the user-provided transmitter location and focal point location to Cartesian
coordinates and calculates the distances between the transmitter and each RIS element.
Then it calculates the distances between the focal point and each RIS element.

Then it computes the necessary phase delay to introduce at each element in order for all
the reflections from each element to be in-phase at the desired focal point. It does this by,
for each element, summing the distance between that element and the transmitter with
the distance between that element and the focal point, multiplying the sum by the
appropriate wavenumber given the transmitter frequency, and then taking the modulus of
the result and 2π. It stores the results for all elements in a matrix that is the same
dimension as the RIS, with each element containing the required phase for the element on
the RIS that corresponds to the row and column the phase value is stored in.


The same process plays out in “get_phases_bin.m”, with the added step at the end of taking
the matrix of ideal, continuous phase values and then stepping through each element and
deciding whether to store either 0 or 180 degrees in the corresponding element of the
binary phase mask. The criteria used for the decision is whether the continuous phase
value lies either on the left-hand or right-hand plane of the unit circle. If the angle measure
lies between 90 degrees and 270 degrees (inclusive), progressing counterclockwise around
the unit circle, it is stored as 180 degrees. If it lies between 270 degrees and 9 0 degrees
(exclusive), progressing counterclockwise around the unit circle, it is stored as 0 degrees.

**plot_E_field.m**

Here is where the value of the reflected wave is calculated in a plane at a given distance
from the RIS (defaulted to be the distance at which the focal point lies, but can be an
arbitrary distance). First a grid of spatial coordinates is computed given the desired
distance and assuming a 2 meter by 2 meter grid lying in the XY-plane centered about the z-
axis (parallel to the RIS). This grid is divided into 50 by 50 elements.

For each of these elements, the script then calculates the magnitude of the wave reflected
by every element of the RIS at that location in space. It then sums the result of all
reflections at that point in order to calculate the total E field magnitude due to the
superposition of all RIS reflections at that point in space. The script then repeats this for all
2500 elements of the reflection grid and plots the result as a heat map.

plot_E_field.m calls “get_E_field()” in order to do the calculation of the superposition of
reflections at each location.

**get_E_field.m**

This is where the total E field magnitude calculation for a particular location takes place. In
this version, it does so by modeling each RIS element only as a center-fed half wave dipole
even though it isn’t accurate; we plan to update the code to reflect the radiation pattern of
a microstrip antenna in the future.

To this end, the formula for the phasor domain wave produced by a center fed half wave
dipole found in Cheng was used to calculate the magnitude of the reflection off of each
element on the RIS at the given location. Since it is assuming the toroidal radiation pattern
of a dipole, the antenna factor is calculated assuming agnosticism to azimuthal angle
(within the XZ-plane) and only takes into account elevation angle (within the YZ-plane)
relative to the measurement point for each RIS element. It calculates the elevation angle


between each RIS element and the measurement location by first defining the vector
between each RIS element and the measurement location, and another vector between
the RIS element and the point directly above or below the measurement point that lies at
the same height (y-coordinate) as the RIS element. Then it uses the formal definition of the
dot product with these two vectors in order to find the angle measure between them
(cos(θ) = ( **a** * **b** ) / || **a** || || **b** ||).

This process is repeated for every RIS element in order to calculate the superposition of all
RIS reflections at that given point in space.

**error_plot.m**

Here is where the matrix of reflection values assuming the binary constraint on phase
values for the RIS is subtracted from the matrix of reflection values assuming an ideal,
continuous phase distribution on the RIS. This difference is then plotted as a heat map for
viewing.

## Operational Instructions

In order to operate the code, follow the following steps:

1. Open “config_CONT.m”.
2. Enter desired values for:
    a.) Transmitter frequency
    b.) RIS panel dimensions (element # in y-dir. by element # in x-dir.)
    c.) Transmitter location relative to RIS in spherical coordinates (assuming RIS panel
       centered about origin in XY-plane)
    d.) Desired focal point location relative to RIS in spherical coordinates (assuming
       RIS panel centered about origin in XY-plane)
    e.) Transmitter EIRP (in Watts)
    f.) Time at which the reflection is to be plotted (t = 0.0 seconds being when Tx
       begins transmitting with 0 phase offset)
    g.) Set “plt_y_n” to “Y” if you wish to view the plot of the phase distribution on the
       RIS; set it to “N” if you do not (if yes, you also must comment out the line
       “cont_plot = plot_E_field(...)”
    h.) Set “SPACE_OR_TIME” to “S” if you want to see the phasor representation of the
       spatial distribution of the reflection; set to “T” to see the temporal distribution at
       a fix location in space


```
i.) Set “FOC_DIST” to desired distance from RIS at which you wish to view the
reflected wave (keep it as-is to view it at the distance at which the desired focal
point lies, or modify it to be an arbitrary distance. Recommended to directly
modify the argument to “Plot_E_field” to replace “FOC_DIST” with desired
distance (in meters) to preserve formula for calculating focal point distance)
j.) Leave “B_OR_C” as equal to “C”! Important to ensure proper function
```
3. Run “config_CONT.m” script to generate matrix of reflection values due to
    continuous phase mask and to view a plot of it.
4. Open “config_BIN.m”.
5. Ensure parameter values a – i (as specified above) are identical to those specified in
    “config_CONT.m” (and that “B_OR_C” remains set to “B”).
6. Run “config_BIN.m” script to generate matrix of reflection values due to binary
    phase mask and to view a plot of it.
7. Open and run “error_plot.m” to generate the difference between the continuous and
    binary reflections and to view a plot of it.
8. (Optional) As in the continuous configuration file, set “plt_y_n” to “Y” and comment
    out “bin_plot = plot_E_field()” in order to view a plot of the binary phase distribution
    on the RIS.
9. (Optional) Open and run “space_animation.m” to generate and save an .mp4 video
    of the reflections at increasing distances from the RIS.
10. (Optional) Open and run “time_animation.m” to generate and save an .mp4 video of
    the reflection at a set distance from the RIS as it progresses through time (an
    appreciable fraction of one cycle).
