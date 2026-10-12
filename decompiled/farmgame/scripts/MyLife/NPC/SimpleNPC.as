package MyLife.NPC
{
   import MyLife.Assets.Avatar.Avatar;
   import MyLife.Assets.Avatar.AvatarActions.AnimationAction;
   import MyLife.Assets.Avatar.Interfaces.IAvatarClothingLoader;
   import MyLife.Events.AvatarLoadEvent;
   import MyLife.Utils.DisplayObjectContainerUtils;
   import com.adobe.serialization.json.JSON;
   import fai.Position;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.utils.getDefinitionByName;
   
   public class SimpleNPC extends MovieClip
   {
      
      public static const GENDER_FEMALE:int = 1;
      
      public static const GENDER_MALE:int = 2;
      
      public static const CHARACTER_STOPPED:String = "MLE_CHARACTER_STOPPED";
      
      public var characterSpeed:int = 150;
      
      public var _characterName:String = "";
      
      public var _renderClip:MovieClip = new MovieClip();
      
      protected var _currentClothing:Object;
      
      protected var _currentCustomizationData:Object;
      
      protected var _gender:int;
      
      protected var _clothesLoader:IAvatarClothingLoader;
      
      private var _avatarScale:Number;
      
      private var m_itemLoadedCallback:Function;
      
      private var m_itemLoading:Object;
      
      public function SimpleNPC(param1:IAvatarClothingLoader, param2:Number = 0.2)
      {
         super();
         addChild(this._renderClip);
         this._clothesLoader = param1;
         this._avatarScale = param2;
         this.createAvatar();
      }
      
      public static function getDefaultCustomizationData() : Object
      {
         return {
            "shirt":{
               "metaData":"",
               "filename":"MaleRowdy",
               "itemId":"1143",
               "name":"Red Tank",
               "categoryId":"101",
               "category":"Shirts",
               "sortOrder":1
            },
            "jacket":{
               "metaData":"",
               "filename":"NewOveralls",
               "itemId":"10564",
               "name":"Black Pants",
               "categoryId":"100",
               "category":"Pants",
               "sortOrder":1
            },
            "ears":{
               "parts":[{
                  "containerClip":"head.leftEar",
                  "partName":"LeftEar"
               },{
                  "containerClip":"head.rightEar",
                  "partName":"RightEar"
               }],
               "itemId":-7
            },
            "nose":{
               "parts":[{
                  "containerClip":"head.nose",
                  "partName":"Nose"
               }],
               "itemId":-6
            },
            "face":{
               "parts":[{
                  "containerClip":"head.face",
                  "partName":"Face"
               }],
               "itemId":-8
            },
            "mouth":{
               "parts":[{
                  "containerClip":"head.mouth",
                  "partName":"Mouth"
               }],
               "itemId":-5
            },
            "hair":{
               "metaData":"Fill:E5D285|Outline:776C42",
               "name":"Spiky Hair",
               "filename":"ShortTosseledHairColor",
               "itemId":"301",
               "catergory":"Hair",
               "categoryId":"1003",
               "sortOrder":22
            },
            "body":{"itemId":2},
            "eyebrows":{
               "parts":[{
                  "containerClip":"head.eyebrows",
                  "partName":"EyeBrows"
               }],
               "itemId":-4
            },
            "pants":{
               "metaData":"",
               "filename":"NewOveralls",
               "itemId":"10564",
               "name":"Black Pants",
               "categoryId":"100",
               "category":"Pants",
               "sortOrder":1
            },
            "eyes":{
               "parts":[{
                  "containerClip":"head.eyes",
                  "partName":"Eyes"
               }],
               "itemId":-3
            },
            "shoes":{
               "metaData":"Fill:000000|Outline:FFFFFF",
               "filename":"MaleShoes",
               "itemId":"1501",
               "name":"Black Shoes",
               "categoryId":"105",
               "category":"Shoes",
               "sortOrder":1
            }
         };
      }
      
      public function get gender() : int
      {
         return this._gender;
      }
      
      public function set gender(param1:int) : void
      {
         this._gender = param1;
         this.getAvatarClip().setGender(param1);
      }
      
      override public function set x(param1:Number) : void
      {
         super.x = param1;
      }
      
      override public function set y(param1:Number) : void
      {
         super.y = param1;
      }
      
      public function setCharacterProperties(param1:*, param2:int, param3:String = "") : void
      {
         this._currentClothing = param1;
         this._gender = param2;
         this._characterName = param3;
      }
      
      public function getRenderClip() : MovieClip
      {
         return this._renderClip;
      }
      
      public function getAvatarClip() : MovieClip
      {
         return this._renderClip.avatarClip;
      }
      
      public function setNewClothing(param1:Object, param2:Boolean = false) : void
      {
         if(param2 == true)
         {
            this._renderClip.avatarClip.loadAvatarClothes(param1,true);
         }
         else
         {
            this._renderClip.avatarClip.renderClothes(param1);
         }
      }
      
      public function loadCharacterClothing(param1:Object) : void
      {
         this.createAvatar();
      }
      
      public function highlightCharacter(param1:Object, param2:Boolean) : void
      {
         var _loc3_:GlowFilter = null;
         if(param2)
         {
            _loc3_ = new GlowFilter();
            _loc3_.color = 16768000;
            _loc3_.blurX = _loc3_.blurY = 10;
            param1.filters = [_loc3_];
         }
         else
         {
            param1.filters = [];
         }
      }
      
      protected function getMovieChildren(param1:MovieClip) : Array
      {
         var _loc4_:DisplayObject = null;
         if(param1 == null)
         {
            return new Array();
         }
         var _loc2_:Array = new Array();
         var _loc3_:int = 0;
         while(_loc3_ < param1.numChildren)
         {
            _loc4_ = param1.getChildAt(_loc3_);
            _loc2_.unshift(_loc4_);
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function setPosition(param1:Position) : void
      {
         this.x = param1.x;
         this.y = param1.y;
      }
      
      public function getPosition() : Position
      {
         return new Position(this.x,this.y);
      }
      
      public function doStop(param1:Boolean = false) : void
      {
         this._renderClip.avatarClip.stopAnimation();
      }
      
      protected function onAvatarLoaded(param1:AvatarLoadEvent) : void
      {
         var _loc2_:Avatar = this._renderClip.avatarClip;
         if(_loc2_)
         {
            _loc2_.buttonMode = true;
            _loc2_.addEventListener(MouseEvent.ROLL_OVER,this.onCharacterMouseOver);
            _loc2_.addEventListener(MouseEvent.ROLL_OUT,this.onCharacterMouseOut);
            _loc2_.doAvatarAction("stand");
         }
         dispatchEvent(new AvatarLoadEvent(AvatarLoadEvent.CHARACTER_LOAD_COMPLETE,this));
      }
      
      protected function onCharacterMouseOver(param1:MouseEvent) : void
      {
         this.highlightCharacter(param1.target,true);
      }
      
      protected function onCharacterMouseOut(param1:MouseEvent) : void
      {
         this.highlightCharacter(param1.target,false);
      }
      
      public function doRandomDance(param1:Boolean = false) : String
      {
         var _loc3_:String = null;
         var _loc2_:Number = Math.round(Math.random() * 3);
         if(_loc2_ == 0)
         {
            _loc3_ = AnimationAction.ROBOT_DANCE;
         }
         else if(_loc2_ == 1)
         {
            _loc3_ = AnimationAction.JUMP_AND_SWING;
         }
         else if(_loc2_ == 2)
         {
            _loc3_ = AnimationAction.ARM_SHUFFLE;
         }
         else if(_loc2_ == 3)
         {
            _loc3_ = AnimationAction.JUMPING_JACKS;
         }
         this.doAvatarAction(_loc3_,param1);
         return _loc3_;
      }
      
      public function doAvatarAction(param1:String, param2:Boolean = false, param3:Object = null) : void
      {
         var _loc4_:Object = new Object();
         _loc4_.id = param1;
         _loc4_.interruptionType = 2;
         if(param3)
         {
            _loc4_.params = param3;
         }
         this._renderClip.avatarClip.doAvatarAction(param1,param3);
      }
      
      public function getDirection() : Number
      {
         return this._renderClip.avatarClip.getDirection();
      }
      
      public function changeDirection(param1:Number) : void
      {
         this._renderClip.avatarClip.changeDirection(param1);
      }
      
      public function cleanUp() : void
      {
         if(this._renderClip)
         {
            removeChild(this._renderClip);
            if(this._renderClip["avatarClip"])
            {
               this._renderClip.avatarClip.removeEventListener(MouseEvent.ROLL_OVER,this.onCharacterMouseOver);
               this._renderClip.avatarClip.removeEventListener(MouseEvent.ROLL_OUT,this.onCharacterMouseOut);
               this._renderClip.avatarClip.parent.removeChild(this._renderClip.avatarClip);
               this._renderClip.avatarClip.removeEventListener(AvatarLoadEvent.CLOTHING_LOAD_COMPLETE,this.onAvatarLoaded);
               this._renderClip.avatarClip = null;
            }
            DisplayObjectContainerUtils.removeChildren(this._renderClip);
            this._renderClip = null;
         }
         this._currentClothing = null;
      }
      
      protected function createAvatar() : void
      {
         while(this._renderClip.numChildren > 0)
         {
            this._renderClip.removeChildAt(0);
         }
         var _loc1_:Class = getDefinitionByName("MyLife.Assets.Avatar.Avatar") as Class;
         var _loc2_:MovieClip = new _loc1_(this._clothesLoader) as MovieClip;
         _loc2_.y = 2;
         this._renderClip.addChild(_loc2_);
         this._renderClip.avatarClip = _loc2_;
         this._renderClip.avatarClip.setParentCharacter(this);
         this._renderClip.avatarClip.initAvatar(this._gender,this._avatarScale);
         this.doAvatarAction("stand");
      }
      
      public function getAvatarCustomizationData() : Object
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc1_:Object = this._currentCustomizationData;
         for(_loc2_ in _loc1_)
         {
            _loc3_ = _loc1_[_loc2_];
            if(_loc3_)
            {
               for each(_loc4_ in ["description","is_new","price_cash","store_category","crew_members","room_ratings","created_on","expire_time","price","active","playerItemId","player"])
               {
                  if(_loc3_.hasOwnProperty(_loc4_))
                  {
                     delete _loc3_[_loc4_];
                  }
               }
            }
            _loc1_[_loc2_] = _loc3_;
         }
         return _loc1_;
      }
      
      public function inferGender(param1:Object, param2:int = 0) : int
      {
         var _loc3_:int = GENDER_FEMALE;
         if(param2 == GENDER_FEMALE || param2 == GENDER_MALE)
         {
            _loc3_ = param2;
         }
         else if(Boolean(param1) && Boolean(param1.hasOwnProperty("body")) && Boolean(param1["body"].hasOwnProperty("g")))
         {
            _loc3_ = int(param1["body"]["g"]);
         }
         return _loc3_;
      }
      
      public function setAvatarCustomizationData(param1:Object, param2:int = 0) : void
      {
         var _loc4_:String = null;
         param1 = this._clothesLoader.parseCustomizationData(param1);
         if(this._renderClip == null || this._renderClip.avatarClip == null)
         {
            this.createAvatar();
         }
         if(param1 == null || !param1)
         {
            param1 = getDefaultCustomizationData();
         }
         else if(param1 is String)
         {
            param1 = com.adobe.serialization.json.JSON.decode(String(param1));
         }
         this._gender = param2 ? param2 : this.inferGender(param1,param2);
         this._currentCustomizationData = param1;
         var _loc3_:Object = this.getDefaultAvatarClothes(this._gender);
         for(_loc4_ in this._currentCustomizationData)
         {
            _loc3_[_loc4_] = this._currentCustomizationData[_loc4_];
         }
         this._currentCustomizationData = _loc3_;
         this.updateAvatarFromCustomizationData();
      }
      
      public function equipItem(param1:Object, param2:Function) : void
      {
         if((!param1.hasOwnProperty("filename") || param1.filename == "") && param1.metaData != "")
         {
            this._renderClip.avatarClip.renderItem(param1);
            this._currentCustomizationData = this._renderClip.avatarClip.getCurrentAvatarClothes();
            this.fillInDefaultClothes();
            if(param2 != null)
            {
               param2();
            }
         }
         else
         {
            this.m_itemLoadedCallback = param2;
            this.m_itemLoading = param1;
            this._clothesLoader.loadClothing([param1],this.onEquipItemLoaded);
         }
      }
      
      private function onEquipItemLoaded() : void
      {
         if(this.m_itemLoading)
         {
            this._renderClip.avatarClip.renderItem(this.m_itemLoading);
            this._currentCustomizationData = this._renderClip.avatarClip.getCurrentAvatarClothes();
            this.fillInDefaultClothes();
            this.m_itemLoading = null;
            if(this.m_itemLoadedCallback != null)
            {
               this.m_itemLoadedCallback();
               this.m_itemLoadedCallback = null;
            }
         }
      }
      
      private function fillInDefaultClothes() : void
      {
         var _loc3_:String = null;
         var _loc1_:Boolean = false;
         var _loc2_:Object = this.getDefaultAvatarClothes(this.gender);
         for(_loc3_ in _loc2_)
         {
            if(this._currentCustomizationData[_loc3_] == null || Number(this._currentCustomizationData[_loc3_]["itemId"]) < 0)
            {
               this._currentCustomizationData[_loc3_] = _loc2_[_loc3_];
               _loc1_ = true;
            }
         }
         if(_loc1_)
         {
            this.setAvatarCustomizationData(this._currentCustomizationData,this.gender);
         }
      }
      
      public function getDefaultAvatarClothes(param1:int) : Object
      {
         return this._clothesLoader.getAllDefaults(param1);
      }
      
      private function updateAvatarFromCustomizationData() : void
      {
         this.transform.colorTransform = new ColorTransform(1,1,1,1,255,255,255);
         this._renderClip.avatarClip.addEventListener(AvatarLoadEvent.CLOTHING_LOAD_COMPLETE,this.avatarCustomizationItemsLoaded);
         this._renderClip.avatarClip.loadAvatarClothes(this._currentCustomizationData);
      }
      
      private function avatarCustomizationItemsLoaded(param1:AvatarLoadEvent) : void
      {
         this._renderClip.avatarClip.removeEventListener(AvatarLoadEvent.CLOTHING_LOAD_COMPLETE,this.avatarCustomizationItemsLoaded);
         this.transform.colorTransform = new ColorTransform();
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

