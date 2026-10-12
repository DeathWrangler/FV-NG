package Classes
{
   import flash.display.Loader;
   
   public class LoaderWithInfo extends Loader
   {
      
      public var info:Object;
      
      public function LoaderWithInfo()
      {
         super();
         this.info = new Object();
      }
   }
}

