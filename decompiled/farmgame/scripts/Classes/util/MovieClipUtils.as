package Classes.util
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   
   public class MovieClipUtils
   {
      
      public function MovieClipUtils()
      {
         super();
      }
      
      public static function recursivePlay(movieClip:MovieClip) : void
      {
         var child:* = undefined;
         var i:* = movieClip.numChildren;
         while(i--)
         {
            child = movieClip.getChildAt(i);
            if(Boolean(child) && Boolean(child.hasOwnProperty("totalFrames")))
            {
               child.play();
               recursivePlay(child);
            }
         }
      }
      
      public static function recursiveStop(container:DisplayObjectContainer) : void
      {
         var mc:MovieClip = null;
         var child:DisplayObject = null;
         var i:* = 0;
         if(container)
         {
            mc = container as MovieClip;
            if(mc)
            {
               mc.stop();
            }
            i = container.numChildren;
            while(i--)
            {
               child = container.getChildAt(i);
               mc = child as MovieClip;
               if(mc)
               {
                  mc.stop();
               }
               recursiveStop(child as DisplayObjectContainer);
            }
         }
      }
   }
}

