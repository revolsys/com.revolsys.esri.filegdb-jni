package com.revolsys.jar;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ClasspathNativeLibraryUtil {
  private static final Map<String, Boolean> LIBRARY_LOADED_MAP = new HashMap<>();

  private static void copy(final InputStream in, final File file) {
    try {
      file.getParentFile().mkdirs();
      try (
        final FileOutputStream out = new FileOutputStream(file)) {
        try {
          final byte[] buffer = new byte[4096];
          int count;
          while ((count = in.read(buffer)) > -1) {
            out.write(buffer, 0, count);
          }
        } catch (final IOException e) {
          throw new RuntimeException(e);
        }
      }
    } catch (final IOException e) {
      throw new RuntimeException("Unable to open file: " + file, e);
    }
  }

  private static String getLibraryExtension() {
    if (OS.IS_WINDOWS) {
      return "dll";
    } else if (OS.IS_MAC) {
      return "dylib";
    } else {
      return "so";
    }
  }

  private static String getLibraryPrefix() {
    if (OS.IS_WINDOWS) {
      return "";
    } else {
      return "lib";
    }
  }

  private static Logger getLogger() {
    return Logger.getLogger(ClasspathNativeLibraryUtil.class.getName());
  }

  private static String getOperatingSystemName() {
    if (OS.IS_WINDOWS) {
      return "winnt";
    } else if (OS.IS_MAC) {
      return "macosx";
    } else if (OS.IS_LINUX) {
      return "linux";
    } else if (OS.IS_SOLARIS) {
      return "solaris";
    } else {
      return OS.OS_NAME;
    }
  }

  public static boolean loadLibrary(final String name) {
    synchronized (LIBRARY_LOADED_MAP) {
      final Boolean loaded = LIBRARY_LOADED_MAP.get(name);
      if (loaded == null) {
        final String prefix = getLibraryPrefix();
        final String ext = getLibraryExtension();
        final String arch = OS.getArch();
        final String operatingSystemName = getOperatingSystemName();
        return loadLibrary(prefix, name, arch, operatingSystemName, ext);
      } else {
        return loaded;
      }
    }
  }

  public static boolean loadLibrary(final String path, final String name) {
    final URL url = ClasspathNativeLibraryUtil.class.getResource(path);
    boolean loaded = false;
    if (url == null) {
      try {
        System.loadLibrary(name);
        loaded = true;
      } catch (final Throwable e) {
        getLogger().log(Level.SEVERE, "Unable to load shared library " + name, e);
      }
    } else {
      try {
        final File directory = newTempDirectory("jni", "name");
        final File file = new File(directory, name + ".dll");
        file.deleteOnExit();
        copy(url.openStream(), file);
        System.load(file.getCanonicalPath());
        loaded = true;
      } catch (final Throwable e) {
        getLogger().log(Level.SEVERE, "Unable to load shared library from classpath " + url, e);
      }
    }
    LIBRARY_LOADED_MAP.put(name, loaded);
    return loaded;
  }

  private static boolean loadLibrary(final String prefix, final String name, final String arch,
    final String operatingSystemName, final String ext) {
    boolean loaded = false;
    final String fileName = prefix + name + "." + ext;
    final String libraryName = "/native/" + operatingSystemName + "/" + arch + "/" + fileName;
    final URL url = ClasspathNativeLibraryUtil.class.getResource(libraryName);
    if (url == null) {
      if (arch.equals("x86_64")) {
        loaded = loadLibrary(prefix, libraryName, "x86", operatingSystemName, ext);
      } else {
        try {
          System.loadLibrary(name);
          loaded = true;
        } catch (final Throwable e) {
          getLogger().log(Level.SEVERE,
            "Unable to load shared library from classpath " + libraryName + " " + fileName, e);
        }
      }
    } else {
      try {
        final File directory = newTempDirectory("jni", "name");
        final File file = new File(directory, fileName);
        file.deleteOnExit();
        copy(url.openStream(), file);
        System.load(file.getCanonicalPath());
        loaded = true;
      } catch (final Throwable e) {
        getLogger().log(Level.SEVERE,
          "Unable to load shared library from classpath " + libraryName + " " + fileName, e);
      }
    }
    LIBRARY_LOADED_MAP.put(name, loaded);
    return loaded;
  }

  private static File newTempDirectory(final String prefix, final String suffix) {
    try {
      final File file = File.createTempFile(prefix, suffix);
      if (!file.delete()) {
        throw new IOException("Cannot delete temporary file");
      }
      if (!file.mkdirs()) {
        throw new IOException("Cannot create temporary directory");
      }
      file.deleteOnExit();
      return file;
    } catch (final Exception e) {
      throw new RuntimeException(e);
    }
  }
}
