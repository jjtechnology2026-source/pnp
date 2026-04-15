using System;
using System.Runtime.InteropServices;

namespace testcs
{
    class Program
    {
    [DllImport("pnpdll64.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi)]
    public static extern IntPtr PFultimo();
    [DllImport("pnpdll64.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi)]
    public static extern IntPtr  PFabrepuerto(string puerto);
    [DllImport("pnpdll64.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi)]
    public static extern IntPtr  PFabrefiscal(string razon,string rif);
    [DllImport("pnpdll64.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi)]
    public static extern IntPtr  PFrenglon(string Descripcion,string cantidad,string monto,string iva);
    [DllImport("pnpdll64.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi)]
    public static extern IntPtr  PFComando(string Comando);
    [DllImport("pnpdll64.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi)]
    public static extern IntPtr  PFtotal();
    [DllImport("pnpdll64.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi)]
    public static extern IntPtr  PFTfiscal(string Texto);
    [DllImport("pnpdll64.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi)]
    public static extern IntPtr  PFultimo(string Texto);
        static void Main(string[] args)
        {    Console.WriteLine("HOLA");
             IntPtr ptr = PFabrepuerto("13");
             string result =  Marshal.PtrToStringAnsi(ptr);
             if (result.Equals("ER")) {
                 Console.WriteLine("ERROR Abriendo Puerto");}
             Console.WriteLine("PFabrepuerto: .{0}.", result);
             ptr = PFabrefiscal("NOMBRE EMPRESA","RIFEMP");
             result =  Marshal.PtrToStringAnsi(ptr);
             Console.WriteLine("PFabrefiscal: .{0}.", result);
             if (result.Equals("ER")) {
                 ptr = PFultimo();
                 result =  Marshal.PtrToStringAnsi(ptr);
                 Console.WriteLine("ERROR Abriendo Facrtura: .{0}.", result);}

             ptr = PFrenglon("Productos","1000","1000","1600");
             result =  Marshal.PtrToStringAnsi(ptr);
             Console.WriteLine("PFrenglon: .{0}.", result);
             if (result.Equals("ER")) {
                 ptr = PFultimo();
                 result =  Marshal.PtrToStringAnsi(ptr);
                 Console.WriteLine("ERROR Renglon producto: .{0}.", result);}

             ptr = PFComando("E|B|1000");
             result =  Marshal.PtrToStringAnsi(ptr);
             Console.WriteLine("PFComando: .{0}.", result);
             if (result.Equals("ER")) {
                 ptr = PFultimo();
                 result =  Marshal.PtrToStringAnsi(ptr);
                 Console.WriteLine("ERROR Comando: .{0}.", result);}

             ptr = PFTfiscal("Texto Libre Forma Pago");
             result =  Marshal.PtrToStringAnsi(ptr);
             Console.WriteLine("PFTfiscal: .{0}.", result);
             if (result.Equals("ER")) {
                 ptr = PFultimo();
                 result =  Marshal.PtrToStringAnsi(ptr);
                 Console.WriteLine("ERROR Texto Fiscal: .{0}.", result);}
             ptr = PFtotal();
             result =  Marshal.PtrToStringAnsi(ptr);
             Console.WriteLine("PFtotal: .{0}.", result);
             if (result.Equals("ER")) {
                 ptr = PFultimo();
                 result =  Marshal.PtrToStringAnsi(ptr);
                 Console.WriteLine("ERROR Cerrando Facrtura: .{0}.", result);}

        }
    }
}