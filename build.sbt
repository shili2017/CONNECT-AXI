// See README.md for license details.

ThisBuild / scalaVersion := "2.13.8"
ThisBuild / version      := "0.1.0"
ThisBuild / organization := "com.github.shili2017"

val chiselVersion = "3.5.1"

lazy val cde = (project in file("cde/build-rules/sbt"))
  .settings(publishArtifact := false)

lazy val root = (project in file("."))
  .settings(
    name := "CONNECT_AXI",
    libraryDependencies ++= Seq(
      "edu.berkeley.cs" %% "chisel3" % chiselVersion,
      "edu.berkeley.cs" %% "chiseltest" % "0.5.1" % "test"
    ),
    scalacOptions ++= Seq(
      "-language:reflectiveCalls",
      "-deprecation",
      "-feature",
      "-Xcheckinit",
      "-P:chiselplugin:genBundleElements",
      "-Xsource:2.13"
    ),
    addCompilerPlugin(("edu.berkeley.cs" % "chisel3-plugin" % chiselVersion).cross(CrossVersion.full))
  )
  .dependsOn(cde)
