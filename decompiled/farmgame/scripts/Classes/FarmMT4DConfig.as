package Classes
{
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import com.troyer.widget.MT4DConfig;
   import flash.display.Loader;
   import flash.events.Event;
   
   public class FarmMT4DConfig extends MT4DConfig
   {
      
      public function FarmMT4DConfig()
      {
         super();
      }
      
      override public function onGetAssetPath(path:String) : String
      {
         if(path.indexOf("http") == -1)
         {
            return Global.getAssetURL(path);
         }
         return Global.getAssetHashPath(path);
      }
      
      override public function onUncompressData(event:Event) : *
      {
         return event.target.data;
      }
      
      override public function onGetLocalizedAssetPath(path:String) : String
      {
         return ZLocUtils.ti(path);
      }
      
      override public function onGetLocalizedString(key:String) : String
      {
         return ZLocUtils.t_pk(key);
      }
      
      override public function loadImage(url:String, errorCallback:Function, completeCallback:Function) : Loader
      {
         return LoadingManager.load(url,completeCallback,0,errorCallback);
      }
      
      override public function overridesLoadImage() : Boolean
      {
         return true;
      }
   }
}

