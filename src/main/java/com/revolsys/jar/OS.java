package com.revolsys.jar;

public class OS {
  public static final String OS_ARCH = System.getProperty("os.arch");

  public final static String OS_NAME = System.getProperty("os.name");

  public final static boolean IS_LINUX = OS_NAME.equals("Linux");

  public final static boolean IS_MAC = OS_NAME.contains("OS X") || OS_NAME.equals("Darwin");

  public final static boolean IS_SOLARIS = OS_NAME.equals("SunOS");

  public final static boolean IS_WINDOWS = OS_NAME.startsWith("Windows");

  public static String getArch() {
    final String osArch = OS_ARCH.toLowerCase();
    if (osArch.equals("i386")) {
      return "x86";
    } else if (osArch.startsWith("amd64") || osArch.startsWith("x86_64")) {
      return "x86_64";
    } else if (osArch.equals("ppc")) {
      return "ppc";
    } else if (osArch.startsWith("ppc")) {
      return "ppc_64";
    } else if (osArch.startsWith("sparc")) {
      return "sparc";
    } else {
      return OS_ARCH;
    }
  }

  public static boolean isMac() {
    return IS_MAC;
  }

  public static boolean isUnix() {
    return IS_SOLARIS || IS_LINUX;
  }

  public static boolean isWindows() {
    return IS_WINDOWS;
  }

}
