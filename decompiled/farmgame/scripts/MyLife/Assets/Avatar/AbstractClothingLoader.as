package MyLife.Assets.Avatar
{
   import MyLife.Assets.Avatar.Interfaces.IAvatarClothingLoader;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   
   public class AbstractClothingLoader extends EventDispatcher implements IAvatarClothingLoader
   {
      
      protected static const knownCategories:Array = ["pants","shirt","hair","eyes","eyebrows","mouth","nose","ears","face"];
      
      public static const pants:Object = {
         "itemId":-1,
         "parts":[{
            "className":"LeftThighPantsFront",
            "containerClip":"leftThigh.clothing"
         },{
            "className":"LeftThighPantsBack",
            "containerClip":"leftThigh.clothing"
         },{
            "className":"RightThighPantsFront",
            "containerClip":"rightThigh.clothing"
         },{
            "className":"RightThighPantsBack",
            "containerClip":"rightThigh.clothing"
         },{
            "className":"PelvisPantsFront",
            "containerClip":"pelvis.clothing"
         },{
            "className":"PelvisPantsBack",
            "containerClip":"pelvis.clothing"
         }]
      };
      
      public static const shirt:Object = {
         "itemId":-2,
         "parts":[{
            "className":"ChestShirtFront",
            "containerClip":"chest.clothing"
         },{
            "className":"ChestShirtBack",
            "containerClip":"chest.clothing"
         }]
      };
      
      public static const hair:Object = {
         "itemId":-9,
         "parts":[{
            "className":"HairFront",
            "containerClip":"head.hair"
         },{
            "className":"HairBack",
            "containerClip":"head.hair"
         }]
      };
      
      public static const eyes:Object = {
         "itemId":-3,
         "parts":[{
            "className":"EyesFront",
            "containerClip":"head.eyes"
         }]
      };
      
      public static const eyebrows:Object = {
         "itemId":-4,
         "parts":[{
            "className":"EyeBrowsFront",
            "containerClip":"head.eyebrows"
         }]
      };
      
      public static const mouth:Object = {
         "itemId":-5,
         "parts":[{
            "className":"MouthFront",
            "containerClip":"head.mouth"
         }]
      };
      
      public static const nose:Object = {
         "itemId":-6,
         "parts":[{
            "className":"NoseFront",
            "containerClip":"head.nose"
         }]
      };
      
      public static const ears:Object = {
         "itemId":-7,
         "parts":[{
            "className":"LeftEarFront",
            "containerClip":"head.leftEar"
         },{
            "className":"LeftEarBack",
            "containerClip":"head.leftEar"
         },{
            "className":"RightEarFront",
            "containerClip":"head.rightEar"
         },{
            "className":"RightEarBack",
            "containerClip":"head.rightEar"
         }]
      };
      
      public static const face:Object = {
         "itemId":-8,
         "parts":[{
            "className":"FaceFront",
            "containerClip":"head.face"
         },{
            "className":"FaceBack",
            "containerClip":"head.face"
         }]
      };
      
      protected var _loadingClothingList:Array;
      
      protected var _callBack:Function;
      
      protected var _loaderIdMap:Dictionary;
      
      public function AbstractClothingLoader()
      {
         super();
         this._loadingClothingList = new Array();
         this._loaderIdMap = new Dictionary();
      }
      
      public function loadClothing(param1:Array, param2:Function = null, param3:Number = 15000, param4:Function = null) : void
      {
         var _loc5_:Object = null;
         var _loc6_:String = null;
         var _loc7_:Loader = null;
         this._loadingClothingList = new Array();
         this._callBack = param2;
         for each(_loc5_ in param1)
         {
            _loc6_ = _loc5_.filename;
            if(_loc6_.indexOf(".swf") == -1)
            {
               _loc6_ += ".swf";
            }
            _loc6_ = this.getAssetPath(_loc6_);
            _loc7_ = this.loadFile(_loc6_);
            this._loaderIdMap[String(_loc5_.itemId)] = {
               "loader":_loc7_,
               "filename":_loc5_.filename
            };
            this._loadingClothingList.push(_loc7_);
         }
      }
      
      public function getIconUrl(param1:String) : String
      {
         return GlobalEngine.getAssetUrl("assets/mylife/item_images/" + param1 + "_60_60.gif");
      }
      
      public function getAsset(param1:String, param2:String = null) : Sprite
      {
         var _loc3_:Class = null;
         var _loc4_:Sprite = null;
         var _loc6_:Object = null;
         var _loc7_:Loader = null;
         var _loc8_:String = null;
         var _loc5_:Number = Number(param1);
         if(param1 == "Default" && Boolean(param2))
         {
            _loc3_ = AvatarParts[param2] as Class;
            _loc4_ = new _loc3_() as Sprite;
         }
         else
         {
            _loc6_ = this._loaderIdMap[param1];
            if(_loc6_)
            {
               _loc7_ = _loc6_.loader;
               _loc8_ = _loc6_.filename;
               if(Boolean(_loc7_) && Boolean(_loc8_))
               {
                  if(param2)
                  {
                     try
                     {
                        _loc3_ = getDefinitionByName("MyLife.Assets." + _loc8_ + "." + param2) as Class;
                        _loc4_ = new _loc3_() as Sprite;
                     }
                     catch(error:Error)
                     {
                     }
                  }
                  else
                  {
                     _loc4_ = _loc7_.content as Sprite;
                  }
               }
            }
         }
         return _loc4_;
      }
      
      public function getCategoryDefaults(param1:String) : Object
      {
         var _loc2_:Object = null;
         if(knownCategories.indexOf(param1) != -1)
         {
            _loc2_ = AbstractClothingLoader[param1];
         }
         return _loc2_;
      }
      
      public function getAllDefaults(param1:int) : Object
      {
         var _loc3_:String = null;
         var _loc2_:Object = {};
         for each(_loc3_ in knownCategories)
         {
            _loc2_[_loc3_] = this.getCategoryDefaults(_loc3_);
         }
         return _loc2_;
      }
      
      public function cancel() : void
      {
         var _loc1_:Loader = null;
         for each(_loc1_ in this._loadingClothingList)
         {
            this.cancelLoader(_loc1_);
            _loc1_ = null;
         }
         this._loadingClothingList = new Array();
      }
      
      public function cleanUp() : void
      {
         this.cancel();
         this._loadingClothingList = null;
         this._loaderIdMap = null;
      }
      
      public function getAssetPath(param1:String) : String
      {
         return param1;
      }
      
      public function getScriptPath() : String
      {
         return "";
      }
      
      public function getItemImagePath(param1:String) : String
      {
         return param1;
      }
      
      protected function cancelLoader(param1:Loader) : void
      {
      }
      
      protected function loadFile(param1:String) : Loader
      {
         return null;
      }
      
      protected function onFileLoaded(param1:Event) : void
      {
         var _loc2_:Number = 0;
         _loc2_ = 0;
         while(_loc2_ < this._loadingClothingList.length)
         {
            if(this._loadingClothingList[_loc2_] == param1.target.loader)
            {
               this._loadingClothingList.splice(_loc2_,1);
            }
            _loc2_++;
         }
         if(this._loadingClothingList.length == 0 && this._callBack != null)
         {
            this._callBack.call();
         }
      }
      
      public function loadClothingCollectionData(param1:Function) : void
      {
         throw new Error("Abstract method loadClothingCollectionData of AbstractClothingLoader called");
      }
      
      public function parseCustomizationData(param1:Object) : Object
      {
         return param1;
      }
      
      public function setRenderQuality(param1:String) : String
      {
         return "";
      }
   }
}

