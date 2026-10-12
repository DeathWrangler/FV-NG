package MyLife
{
   import flash.display.MovieClip;
   
   public class MyLifeInstance
   {
      
      private static var _myLife:MovieClip;
      
      public static const RIGHT_FRONT:Number = 0;
      
      public static const LEFT_FRONT:Number = 1;
      
      public static const RIGHT_BACK:Number = 2;
      
      public static const LEFT_BACK:Number = 3;
      
      private static const _instance:MyLifeInstance = new MyLifeInstance();
      
      public function MyLifeInstance()
      {
         super();
         if(_instance != null)
         {
            throw new Error("MyLifeInstance: Please use getInstance() to access class.");
         }
      }
      
      public static function getClassInstance() : MyLifeInstance
      {
         return _instance;
      }
      
      public static function getInstance() : MovieClip
      {
         _myLife = _myLife || new MovieClip();
         return _myLife;
      }
      
      public function setMyLifeInstance(param1:MovieClip) : void
      {
         _myLife = param1;
      }
   }
}

