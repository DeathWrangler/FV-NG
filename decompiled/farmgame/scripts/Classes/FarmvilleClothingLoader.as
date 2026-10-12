package Classes
{
   import Classes.Avatar.AvatarItem;
   import Engine.Managers.LoadingManager;
   import MyLife.Assets.Avatar.AbstractClothingLoader;
   import flash.display.Loader;
   import flash.events.Event;
   
   public class FarmvilleClothingLoader extends AbstractClothingLoader
   {
      
      public static const FV_AVATAR_VERSIONFIELD:String = "version";
      
      public static const FV_AVATAR_VERSIONFIELD_OLD:String = "v";
      
      public static const FV_AVATAR_VERSION_LATEST:String = "fv_1";
      
      public static const FV_AVATAR_VERSION_PREOCT2010:String = "1";
      
      public static const FV_AVATAR_VERSION_PREOCT2010_REQUIREDITEMS:Array = ["hair","makeup","nose","face","skin","body","eyebrows","mouth","eyes","ears"];
      
      public function FarmvilleClothingLoader()
      {
         super();
      }
      
      override public function getAllDefaults(gender:int) : Object
      {
         var genderStr:String = gender == 2 ? "male" : "female";
         return Global.avatarConfigSettings.getDefaultRawCustomizationData(genderStr);
      }
      
      override public function getIconUrl(key:String) : String
      {
         var result:String = "";
         var avatarItem:AvatarItem = Global.avatarConfigSettings.getItemById(key);
         if(avatarItem)
         {
            result = avatarItem.iconPath;
         }
         else
         {
            result = super.getIconUrl(key);
         }
         return result;
      }
      
      override public function getAssetPath(filename:String) : String
      {
         var flashVars:Object = GlobalEngine.getFlashVars();
         if(flashVars.hasOwnProperty("localAvatar") && Boolean(flashVars["localAvatar"]))
         {
            return "../src/assets/mylife/avatar_assets/" + filename;
         }
         return Global.getAssetURL("assets/mylife/avatar_assets/" + filename);
      }
      
      override public function getScriptPath() : String
      {
         return Config.BASE_PATH + "/mylife_game_control/";
      }
      
      override public function getItemImagePath(filename:String) : String
      {
         var flashVars:Object = GlobalEngine.getFlashVars();
         if(flashVars.hasOwnProperty("localAvatar") && Boolean(flashVars["localAvatar"]))
         {
            return "../src/assets/mylife/item_images/" + filename;
         }
         return Global.getAssetURL("assets/mylife/item_images/" + filename);
      }
      
      override protected function cancelLoader(loader:Loader) : void
      {
         LoadingManager.cancelLoad(loader);
      }
      
      override protected function loadFile(url:String) : Loader
      {
         var failCallback:Function = function(e:Event):void
         {
         };
         var successCallback:Function = function(e:Event):void
         {
            onFileLoaded(e);
         };
         var loader:Loader = LoadingManager.load(url,successCallback,LoadingManager.PRIORITY_NORMAL,failCallback);
         return loader;
      }
      
      override public function loadClothingCollectionData(callback:Function) : void
      {
         callback(Global.avatarConfigSettings.getRawNonClothingItems());
      }
      
      private function getCustomizationVersion(data:Object) : String
      {
         var version:String = null;
         if(data.hasOwnProperty(FV_AVATAR_VERSIONFIELD))
         {
            version = data[FV_AVATAR_VERSIONFIELD];
         }
         else if(data.hasOwnProperty(FV_AVATAR_VERSIONFIELD_OLD))
         {
            version = data[FV_AVATAR_VERSIONFIELD_OLD];
         }
         return version;
      }
      
      override public function parseCustomizationData(data:Object) : Object
      {
         var version:String = this.getCustomizationVersion(data);
         var result:Object = data;
         switch(version)
         {
            case FV_AVATAR_VERSION_LATEST:
               result = this.parseFVVersion1(data);
               break;
            case FV_AVATAR_VERSION_PREOCT2010:
               result = this.parseFVPreOct2010(data);
         }
         return result;
      }
      
      public function parseFVPreOct2010(customizationData:Object) : Object
      {
         var i:Object = null;
         var reqIndex:int = 0;
         var key:String = null;
         var cPart:Object = null;
         var avatarItem:AvatarItem = null;
         var genderInt:int = customizationData["g"] == "f" ? 1 : 2;
         var data:Object = {};
         for(i in customizationData)
         {
            if(i.toString().charAt(0) == "p" && i.toString().length > 1)
            {
               reqIndex = parseInt(i.toString().substr(1));
               if(reqIndex >= 0 && reqIndex < FV_AVATAR_VERSION_PREOCT2010_REQUIREDITEMS.length)
               {
                  key = FV_AVATAR_VERSION_PREOCT2010_REQUIREDITEMS[reqIndex];
                  cPart = customizationData[i];
                  if(cPart.hasOwnProperty("i"))
                  {
                     avatarItem = Global.avatarConfigSettings.getItemById(cPart["i"]);
                     if(avatarItem)
                     {
                        data[key] = avatarItem.toRawObject();
                     }
                  }
               }
            }
         }
         return data;
      }
      
      private function parseFVVersion1(data:Object) : Object
      {
         var key:String = null;
         var item:Object = null;
         var avatarItem:AvatarItem = null;
         var result:Object = {};
         var items:Object = {};
         if(data.hasOwnProperty("items"))
         {
            items = data.items;
         }
         for(key in items)
         {
            item = items[key];
            if(item.hasOwnProperty("itemId"))
            {
               avatarItem = Global.avatarConfigSettings.getItemById(item["itemId"]);
               if(avatarItem)
               {
                  result[key] = avatarItem.toRawObject();
               }
            }
         }
         return result;
      }
      
      override public function setRenderQuality(quality:String) : String
      {
         var currentQuality:String = Global.stage.quality;
         Global.stage.quality = quality;
         return currentQuality;
      }
   }
}

