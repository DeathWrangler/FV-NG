package MyLife.Assets.Avatar
{
   import MyLife.Assets.Avatar.Interfaces.IAvatarClothingLoader;
   import MyLife.Clothes.SimpleClothingItem;
   import MyLife.MyLifeUtils;
   import MyLife.Utils.DisplayObjectContainerUtils;
   import MyLife.Utils.DisplayObjectUtils;
   import MyLife.Utils.StringUtils;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.StageQuality;
   import flash.geom.ColorTransform;
   
   public class ClothingConflictManager
   {
      
      private static var defaultParts:Array = ["","pants","shirt","eyes","eyebrows","mouth","nose","ears","face","hair"];
      
      private static var nonSmoothedParts:Array = ["Eyes","Eyebrows","Nose","Mouth"];
      
      private var clothingList:Object;
      
      private var renderedPartList:Object;
      
      private var categoryToIDMapping:Object;
      
      private var noDeleteCategoryToIDMapping:Object;
      
      private var avatar:*;
      
      private var skinFillColor:Number;
      
      private var skinOutlineColor:Number;
      
      private var tempSkinFillColor:Number = -1;
      
      private var tempSkinOutlineColor:Number = -1;
      
      private var tempSkinFillColor2:Number = -1;
      
      private var tempSkinOutlineColor2:Number = -1;
      
      private var skinChangeItemId:Number = -1;
      
      private var invisibleSkinFill:Number;
      
      private var isSetCostumeSkinColor:Boolean = false;
      
      private var isWearingSwimsuitTop:Boolean;
      
      private var isWearingSwimsuitBottom:Boolean;
      
      private var _isWearingCarCostume:Boolean;
      
      private var isInvisible:Boolean = false;
      
      private var _clothesLoader:IAvatarClothingLoader;
      
      public function ClothingConflictManager(param1:*, param2:IAvatarClothingLoader)
      {
         super();
         this.categoryToIDMapping = new Object();
         this.noDeleteCategoryToIDMapping = new Object();
         this.clothingList = new Object();
         this.renderedPartList = new Object();
         this.avatar = param1;
         this._clothesLoader = param2;
         this.clearAllClothes(param1.avatarFrontClip);
         this.clearAllClothes(param1.avatarBackClip);
      }
      
      public function get isWearingCarCostume() : Boolean
      {
         return this._isWearingCarCostume;
      }
      
      public function set isWearingCarCostume(param1:Boolean) : void
      {
         this._isWearingCarCostume = param1;
      }
      
      private function clearAllClothes(param1:MovieClip) : void
      {
         var _loc4_:MovieClip = null;
         var _loc2_:Array = SimpleClothingItem.ALL_VIEWS;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = this.getContainerClip(_loc2_[_loc3_].containerClip,param1);
            if(_loc4_ != null)
            {
               if(_loc4_.numChildren > 0)
               {
                  DisplayObjectContainerUtils.removeChildren(_loc4_);
               }
            }
            _loc3_++;
         }
      }
      
      public function renderClothes(param1:Object = null) : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         if(param1 == null)
         {
            param1 = MyLifeUtils.cloneObject(this.categoryToIDMapping);
         }
         for each(_loc3_ in this.categoryToIDMapping)
         {
            if(this.clothingList[_loc3_.itemId] != null)
            {
               delete this.clothingList[_loc3_.itemId];
               _loc6_ = _loc3_.asset;
               if((Boolean(_loc6_)) && _loc6_.hasOwnProperty("onRemoveItem"))
               {
                  _loc6_.onRemoveItem(this.avatar);
               }
            }
         }
         this.categoryToIDMapping = new Object();
         this.clothingList = new Object();
         this.renderedPartList = new Object();
         this.clearAllClothes(this.avatar.avatarFrontClip);
         this.clearAllClothes(this.avatar.avatarBackClip);
         this.skinChangeItemId = -1;
         this.tempSkinFillColor = -1;
         this.tempSkinOutlineColor = -1;
         _loc4_ = {};
         for(_loc2_ in param1)
         {
            if(param1[_loc2_] != null)
            {
               this.checkForTemporarySkinColor(param1[_loc2_]);
            }
         }
         for(_loc2_ in param1)
         {
            if(param1[_loc2_] != null)
            {
               if(_loc2_.indexOf("_temp") > 0 || param1[_loc2_].rental == 1)
               {
                  param1[_loc2_].rental = 1;
                  _loc4_[_loc2_] = param1[_loc2_];
               }
               else if(param1[_loc2_] != null)
               {
                  this.addClothingItem(param1[_loc2_],false);
               }
            }
         }
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_ != null)
            {
               this.addClothingItem(_loc5_,false);
            }
         }
         this.completeRendering();
      }
      
      private function completeRendering() : void
      {
         var _loc1_:String = null;
         var _loc2_:int = 0;
         var _loc3_:String = null;
         for(_loc1_ in this.categoryToIDMapping)
         {
            _loc2_ = _loc1_.indexOf("_temp");
            if(_loc2_ >= 0)
            {
               _loc3_ = _loc1_.substring(0,_loc2_);
               if(!this.categoryToIDMapping[_loc3_] && Boolean(this.noDeleteCategoryToIDMapping[_loc3_]))
               {
                  this.categoryToIDMapping[_loc3_] = this.noDeleteCategoryToIDMapping[_loc3_];
               }
            }
         }
         this.replaceMissingRequiredClothes();
         this.tintSkin(this.avatar.avatarFrontClip);
         this.tintSkin(this.avatar.avatarBackClip);
      }
      
      public function addClothingItem(param1:Object, param2:Boolean = true, param3:Number = -1, param4:String = "") : void
      {
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc8_:String = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Array = null;
         var _loc12_:Number = NaN;
         var _loc13_:Array = null;
         var _loc5_:Boolean = false;
         if(param1.itemId == null || isNaN(param1.itemId))
         {
            if(param1.id)
            {
               param1.itemId = param1.id;
               delete param1.id;
            }
            else if(param1.item_id)
            {
               param1.itemId = param1.item_id;
               delete param1.item_id;
            }
            else if(param1.item)
            {
               param1.itemId = param1.item;
               delete param1.item;
            }
         }
         if(param1.categoryId == null || isNaN(param1.categoryId))
         {
            if(param1.item_category_id)
            {
               param1.categoryId = param1.item_category_id;
               delete param1.item_category_id;
            }
         }
         if(param1.metaData == null)
         {
            if(param1.meta_data)
            {
               param1.metaData = param1.meta_data;
               delete param1.meta_data;
            }
         }
         if(param1.itemId == 0)
         {
            _loc8_ = this.convertLabelToSaveReadyLabel(param1.category);
            if(defaultParts.indexOf(_loc8_) >= 0)
            {
               this.renderDefaultClothing(_loc8_,false);
            }
            else if(param3 != -1)
            {
               this.removeClothingItem(param3);
            }
         }
         else if(param1.categoryId == 1000)
         {
            if(param1.gender == null)
            {
               param1.gender = 1;
            }
            if(isNaN(this.avatar.getGender()) || this.avatar.getGender() == 0)
            {
               this.avatar.initAvatar(param1.gender,this.avatar.scaleX);
            }
            this.setCategoryIDMapping("body",param1);
            _loc6_ = param1.metaData == null ? param1.meta_data : param1.metaData;
            _loc7_ = StringUtils.convertMetaDataStringToObject(_loc6_);
            _loc9_ = Number("0x" + _loc7_.Fill);
            _loc10_ = Number("0x" + _loc7_.Outline);
            if(!this.isSetCostumeSkinColor)
            {
               if(_loc9_ != this.skinFillColor || _loc10_ != this.skinOutlineColor)
               {
                  _loc5_ = true;
               }
               this.skinFillColor = _loc9_;
               this.skinOutlineColor = _loc10_;
            }
            else
            {
               this.tempSkinFillColor2 = _loc9_;
               this.tempSkinOutlineColor2 = _loc10_;
            }
         }
         else if(this.clothingList[param1.itemId] == null || Boolean(param4))
         {
            _loc11_ = this.getPartList(param1,param4);
            if(_loc11_ != null && _loc11_.length > 0)
            {
               _loc6_ = param1.metaData == null ? param1.meta_data : param1.metaData;
               _loc7_ = StringUtils.convertMetaDataStringToObject(_loc6_);
               if(Boolean(_loc7_.SkinFill) && Boolean(_loc7_.SkinOutline))
               {
                  if(this.tempSkinFillColor == -1 || this.tempSkinOutlineColor == -1 || this.skinChangeItemId == -1)
                  {
                     _loc5_ = true;
                  }
                  this.invisibleSkinFill = _loc7_.SkinFill;
                  this.tempSkinFillColor = Number("0x" + _loc7_.SkinFill);
                  this.tempSkinOutlineColor = Number("0x" + _loc7_.SkinOutline);
                  this.skinChangeItemId = param1.itemId;
               }
               if(param1.metaData != null && param1.metaData.indexOf("SkinColor:") >= 0 && param1.category == "costume")
               {
                  this.isSetCostumeSkinColor = true;
                  _loc12_ = 0;
                  _loc13_ = param1.metaData.split(":");
                  _loc12_ = Number("0x" + _loc13_[1]);
                  this.skinFillColor = _loc12_;
                  this.tintSkin(this.avatar.avatarFrontClip);
                  this.tintSkin(this.avatar.avatarBackClip);
               }
               else if(param1.category == "costume" && this.tempSkinFillColor2 != -1 && this.tempSkinOutlineColor2 != -1)
               {
                  this.skinFillColor = this.tempSkinFillColor2;
                  this.skinOutlineColor = this.tempSkinOutlineColor2;
                  this.tintSkin(this.avatar.avatarFrontClip);
                  this.tintSkin(this.avatar.avatarBackClip);
               }
               if(Boolean(param1.asset) && Boolean(param1.asset.hasOwnProperty("onWearItem")))
               {
                  param1.asset.onWearItem(this.avatar);
               }
               if(_loc7_.isCarCostume)
               {
                  this._isWearingCarCostume = true;
               }
               this.clothingList[param1.itemId] = _loc11_;
            }
         }
         if(_loc5_)
         {
            this.renderClothes(this.getFormattedClothingList());
         }
         else if(param2)
         {
            this.completeRendering();
         }
      }
      
      private function checkForTemporarySkinColor(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         if(Boolean(param1) && param1.categoryId != 1000)
         {
            _loc4_ = this.getPartList(param1);
            if(_loc4_ != null && _loc4_.length > 0)
            {
               _loc2_ = param1.metaData == null ? param1.meta_data : param1.metaData;
               _loc3_ = StringUtils.convertMetaDataStringToObject(_loc2_);
               if(Boolean(_loc3_.SkinFill) && Boolean(_loc3_.SkinOutline))
               {
                  this.tempSkinFillColor = Number("0x" + _loc3_.SkinFill);
                  this.tempSkinOutlineColor = Number("0x" + _loc3_.SkinOutline);
                  this.skinChangeItemId = param1.itemId;
               }
            }
         }
      }
      
      private function tintClip(param1:MovieClip) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(param1)
         {
            if(isNaN(this.skinFillColor))
            {
               this.skinFillColor = 16768169;
            }
            if(isNaN(this.skinOutlineColor))
            {
               this.skinOutlineColor = 8086080;
            }
            _loc2_ = this.skinChangeItemId != -1 ? this.tempSkinFillColor : this.skinFillColor;
            _loc3_ = this.skinChangeItemId != -1 ? this.tempSkinOutlineColor : this.skinOutlineColor;
            this.colorClip(param1,_loc2_,_loc3_);
         }
      }
      
      public function tintSkin(param1:MovieClip) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(isNaN(this.skinFillColor))
         {
            this.skinFillColor = 16768169;
         }
         if(isNaN(this.skinOutlineColor))
         {
            this.skinOutlineColor = 8086080;
         }
         var _loc2_:Number = this.skinChangeItemId != -1 ? this.tempSkinFillColor : this.skinFillColor;
         var _loc3_:Number = this.skinChangeItemId != -1 ? this.tempSkinOutlineColor : this.skinOutlineColor;
         this.colorClip(param1.chest.skin,_loc2_,_loc3_);
         this.colorClip(param1.rightUpperArm.skin,_loc2_,_loc3_);
         this.colorClip(param1.rightForeArm.skin,_loc2_,_loc3_);
         this.colorClip(param1.rightHand.skin,_loc2_,_loc3_);
         this.colorClip(param1.leftUpperArm.skin,_loc2_,_loc3_);
         this.colorClip(param1.leftForeArm.skin,_loc2_,_loc3_);
         this.colorClip(param1.leftHand.skin,_loc2_,_loc3_);
         this.colorClip(param1.pelvis.skin,_loc2_,_loc3_);
         this.colorClip(param1.rightThigh.skin,_loc2_,_loc3_);
         this.colorClip(param1.rightCalf.skin,_loc2_,_loc3_);
         this.colorClip(param1.rightFoot.skin,_loc2_,_loc3_);
         this.colorClip(param1.leftThigh.skin,_loc2_,_loc3_);
         this.colorClip(param1.leftCalf.skin,_loc2_,_loc3_);
         this.colorClip(param1.leftFoot.skin,_loc2_,_loc3_);
      }
      
      private function replaceMissingRequiredClothes() : void
      {
         var _loc1_:Number = 1;
         while(_loc1_ < defaultParts.length)
         {
            this.renderDefaultClothing(defaultParts[_loc1_],true);
            _loc1_++;
         }
      }
      
      private function isClothingSlotSet(param1:String) : Boolean
      {
         if(!(this.categoryToIDMapping[param1] == null || this.categoryToIDMapping[param1].itemId == 0 || this.categoryToIDMapping[param1].itemId == null))
         {
            return true;
         }
         return false;
      }
      
      private function renderDefaultClothing(param1:String, param2:Boolean) : void
      {
         if(param2)
         {
            if(this.isClothingSlotSet(param1) || this.isClothingSlotSet(param1 + "_temp"))
            {
               return;
            }
         }
         var _loc3_:Object = this._clothesLoader.getCategoryDefaults(param1);
         if(param1 == "shirt")
         {
            this.isWearingSwimsuitTop = false;
         }
         if(param1 == "pants")
         {
            this.isWearingSwimsuitBottom = false;
         }
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:Array = this.getPartList(_loc3_);
         if(_loc4_.length > 0)
         {
            this.clothingList[_loc3_.itemId] = _loc4_;
            this.setCategoryIDMapping(param1,_loc3_);
         }
      }
      
      private function getClothingClip(param1:Number, param2:String, param3:String, param4:String = "") : Sprite
      {
         var clothingClip:Sprite = null;
         var genderString:String = null;
         var className:String = null;
         var name:String = null;
         var id:Number = param1;
         var direction:String = param2;
         var partName:String = param3;
         var stateName:String = param4;
         if(id < 0)
         {
            try
            {
               genderString = "";
               if(partName == "ChestShirt" || partName == "Eyes" || partName == "Mouth" || partName == "Nose" || partName == "EyeBrows")
               {
                  genderString = this.avatar.getGender() == 1 ? "Female" : "Male";
               }
               className = genderString + partName + direction;
               clothingClip = this._clothesLoader.getAsset("Default",className);
            }
            catch(error:Error)
            {
               clothingClip = null;
            }
         }
         else
         {
            name = partName + direction;
            if(Boolean(stateName) && stateName != "Default")
            {
               name += "." + stateName;
            }
            clothingClip = this._clothesLoader.getAsset(String(id),name);
         }
         return clothingClip;
      }
      
      private function splitClassNameIntoPartNameAndDirection(param1:String) : Array
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc2_:Number = param1.lastIndexOf("Front");
         if(_loc2_ == -1)
         {
            _loc2_ = param1.lastIndexOf("Back");
            if(_loc2_ != -1)
            {
               _loc3_ = "Back";
            }
         }
         else
         {
            _loc3_ = "Front";
         }
         if(_loc3_ != null)
         {
            _loc4_ = param1.substring(0,_loc2_);
         }
         else
         {
            _loc4_ = param1;
         }
         return [_loc4_,_loc3_];
      }
      
      private function getPartList(param1:Object, param2:String = "") : Array
      {
         var _loc6_:Array = null;
         var _loc7_:Object = null;
         var _loc10_:String = null;
         var _loc11_:Array = null;
         var _loc12_:String = null;
         var _loc13_:String = null;
         var _loc14_:MovieClip = null;
         var _loc15_:MovieClip = null;
         var _loc16_:Sprite = null;
         var _loc3_:Number = Number(param1.itemId);
         var _loc4_:String = param1.metaData == null ? param1.meta_data : param1.metaData;
         var _loc5_:Object = StringUtils.convertMetaDataStringToObject(_loc4_);
         if(!param1.asset)
         {
            _loc7_ = this._clothesLoader.getAsset(String(_loc3_));
            param1.asset = _loc7_;
         }
         else
         {
            _loc7_ = param1.asset;
         }
         if(_loc3_ < 0 && _loc3_ > -100)
         {
            _loc10_ = defaultParts[-_loc3_];
            _loc6_ = MyLifeUtils.cloneObject(this._clothesLoader.getCategoryDefaults(_loc10_).parts);
         }
         else if(Boolean(_loc7_) && _loc7_.hasOwnProperty("getPartList"))
         {
            _loc6_ = _loc7_.getPartList();
         }
         else
         {
            _loc6_ = MyLifeUtils.cloneObject(SimpleClothingItem.ALL_VIEWS);
         }
         if(_loc6_ == null)
         {
            return null;
         }
         var _loc8_:Object = {};
         var _loc9_:Number = 0;
         while(_loc9_ < _loc6_.length)
         {
            _loc11_ = this.splitClassNameIntoPartNameAndDirection(_loc6_[_loc9_].className);
            _loc12_ = _loc11_[0];
            _loc13_ = _loc11_[1];
            _loc14_ = _loc13_ == "Front" ? this.avatar.avatarFrontClip : this.avatar.avatarBackClip;
            _loc15_ = this.getContainerClip(_loc6_[_loc9_].containerClip,_loc14_);
            if(_loc3_ > -100)
            {
               _loc16_ = this.getClothingClip(_loc3_,_loc13_,_loc12_,param2);
               if(_loc16_)
               {
                  _loc16_.name = _loc12_;
               }
            }
            else
            {
               _loc16_ = _loc7_ as MovieClip;
            }
            if(_loc16_ != null)
            {
               if(_loc8_[_loc12_] == null)
               {
                  _loc8_[_loc12_] = _loc12_;
                  if(this.renderedPartList[_loc12_] != null)
                  {
                     this.removeClothingItem(this.renderedPartList[_loc12_]);
                  }
                  if(_loc12_ == "ChestShirt")
                  {
                     this.isWearingSwimsuitTop = param1.categoryId == 2020;
                  }
                  if(_loc12_ == "PelvisPants")
                  {
                     this.isWearingSwimsuitBottom = param1.categoryId == 2020;
                  }
                  this.setCategoryIDMapping(_loc12_,param1);
                  this.renderedPartList[_loc12_] = _loc3_;
               }
               if(_loc15_ != null)
               {
                  this.replaceClothingOnPart(_loc15_,_loc16_,_loc3_,_loc5_);
               }
            }
            else
            {
               _loc6_.splice(_loc9_,1);
               _loc9_--;
            }
            _loc9_++;
         }
         return _loc6_;
      }
      
      private function addPart(param1:String, param2:String, param3:Number, param4:MovieClip, param5:Object) : Boolean
      {
         var _loc6_:String = param4 == this.avatar.avatarFrontClip ? "Front" : "Back";
         var _loc7_:MovieClip = this.getContainerClip(param2,param4);
         var _loc8_:Sprite = this.getClothingClip(param3,_loc6_,param1);
         if(_loc8_ != null)
         {
            this.replaceClothingOnPart(_loc7_,_loc8_,param3,param5);
            return true;
         }
         return false;
      }
      
      private function convertLabelToSaveReadyLabel(param1:String) : String
      {
         var _loc2_:String = null;
         if(param1 == "PelvisPants" || param1 == "Pants" || param1 == "Dresses" || param1 == "Skirts" || param1 == "Costumes")
         {
            _loc2_ = "pants";
         }
         else if(param1 == "ChestShirt" || param1 == "Shirts")
         {
            _loc2_ = "shirt";
         }
         else if(param1 == "ChestJacket" || param1 == "Jackets")
         {
            _loc2_ = "jacket";
         }
         else if(param1 == "Eyes")
         {
            _loc2_ = "eyes";
         }
         else if(param1 == "EyeBrows")
         {
            _loc2_ = "eyebrows";
         }
         else if(param1 == "Mouth")
         {
            _loc2_ = "mouth";
         }
         else if(param1 == "FacialHair" || param1 == "Facial Hair")
         {
            _loc2_ = "facialhair";
         }
         else if(param1 == "Nose")
         {
            _loc2_ = "nose";
         }
         else if(param1 == "Hair")
         {
            _loc2_ = "hair";
         }
         else if(param1 == "Glasses")
         {
            _loc2_ = "glasses";
         }
         else if(param1 == "Hat" || param1 == "Hats")
         {
            _loc2_ = "hat";
         }
         else if(param1 == "LeftEar")
         {
            _loc2_ = "ears";
         }
         else if(param1 == "Face")
         {
            _loc2_ = "face";
         }
         else if(param1 == "LeftFootShoe" || param1 == "Shoes" || param1 == "RightFootShoe")
         {
            _loc2_ = "shoes";
         }
         else if(param1 == "Necklace" || param1 == "ChestNecklace")
         {
            _loc2_ = "necklace";
         }
         else if(param1 == "RightHandItem" || param1 == "Purse" || param1 == "LeftHandItem")
         {
            _loc2_ = "purse";
         }
         else if(param1 == "Makeup")
         {
            _loc2_ = "makeup";
         }
         else if(param1 == "Belt")
         {
            _loc2_ = "belt";
         }
         else if(param1 == "Gloves" || param1 == "LeftHandGlove" || param1 == "RightHandGlove")
         {
            _loc2_ = "gloves";
         }
         else if(param1 == "Ring" || param1 == "LeftHandRing" || param1 == "RightHandRing")
         {
            _loc2_ = "ring";
         }
         else if(param1 == "LeftForeArmBracelet" || param1 == "RightForeArmBracelet" || param1 == "Bracelet")
         {
            _loc2_ = "bracelet";
         }
         else if(param1 == "Scarf" || param1 == "ChestScarf")
         {
            _loc2_ = "scarf";
         }
         else if(param1 == "LeftEarring")
         {
            _loc2_ = "earrings";
         }
         else if(param1 == "body")
         {
            return "body";
         }
         return _loc2_;
      }
      
      private function setCategoryIDMapping(param1:String, param2:Object) : void
      {
         var _loc4_:* = undefined;
         var _loc5_:Object = null;
         var _loc6_:String = null;
         var _loc3_:String = this.convertLabelToSaveReadyLabel(param1);
         if(_loc3_ != null)
         {
            if(param2)
            {
               if(param2.rental)
               {
                  this.categoryToIDMapping[_loc3_ + "_temp"] = param2;
                  this.noDeleteCategoryToIDMapping[_loc3_ + "_temp"] = param2;
               }
               else
               {
                  this.categoryToIDMapping[_loc3_] = param2;
                  if(this.categoryToIDMapping[_loc3_ + "_temp"] != null)
                  {
                     _loc5_ = this.categoryToIDMapping[_loc3_ + "_temp"];
                     for(_loc6_ in this.categoryToIDMapping)
                     {
                        if(_loc6_.indexOf("_temp") > 0)
                        {
                           if(this.categoryToIDMapping[_loc6_].itemId == _loc5_.itemId)
                           {
                              delete this.categoryToIDMapping[_loc6_];
                           }
                        }
                     }
                  }
                  this.noDeleteCategoryToIDMapping[_loc3_] = param2;
               }
            }
            else
            {
               delete this.categoryToIDMapping[_loc3_];
               delete this.categoryToIDMapping[_loc3_ + "_temp"];
            }
         }
      }
      
      public function getClothingItem(param1:String) : Object
      {
         return this.categoryToIDMapping[param1];
      }
      
      private function checkAnimated(param1:Sprite) : Boolean
      {
         var _loc4_:MovieClip = null;
         var _loc2_:Boolean = false;
         var _loc3_:* = param1.numChildren;
         while(Boolean(_loc3_) && _loc2_ == false)
         {
            _loc3_--;
            _loc4_ = param1.getChildAt(_loc3_) as MovieClip;
            if(_loc4_)
            {
               if(_loc4_.totalFrames > 1 || _loc4_.numChildren == 0)
               {
                  _loc2_ = true;
               }
               else
               {
                  _loc2_ = this.checkAnimated(_loc4_);
               }
            }
         }
         return _loc2_;
      }
      
      private function replaceClothingOnPart(param1:MovieClip, param2:Sprite, param3:Number, param4:Object = null) : void
      {
         var _loc5_:Boolean = false;
         var _loc6_:Sprite = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:MovieClip = null;
         var _loc10_:Boolean = false;
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc13_:Bitmap = null;
         if(param1 == null)
         {
            return;
         }
         if(param1.numChildren > 0)
         {
            DisplayObjectContainerUtils.removeChildren(param1);
         }
         if(param2 == null)
         {
            param1.itemId = 0;
         }
         else
         {
            param1.itemId = param3;
            if(param4.Fill != null)
            {
               _loc7_ = Number("0x" + param4.Fill);
               _loc8_ = Number("0x" + param4.Outline);
               this.colorClip(param2,_loc7_,_loc8_);
               if(param2.getChildByName("color") == null)
               {
                  _loc9_ = new MovieClip();
                  _loc9_.addChild(param2);
                  param2 = _loc9_;
               }
            }
            if("skin" in param2 && Boolean(param2["skin"]))
            {
               this.tintClip(param2["skin"]);
            }
            _loc5_ = this.checkAnimated(param2);
            _loc6_ = param2;
            if(!_loc5_)
            {
               _loc6_ = new MovieClip();
               _loc10_ = true;
               for each(_loc11_ in nonSmoothedParts)
               {
                  if(param2.name == _loc11_)
                  {
                     _loc10_ = false;
                     break;
                  }
               }
               _loc12_ = this._clothesLoader.setRenderQuality(StageQuality.HIGH);
               _loc13_ = DisplayObjectUtils.getBitmap(param2,this.avatar.scaleX,_loc10_);
               _loc13_.x = param2.getBounds(param2).left * this.avatar.scaleX;
               _loc13_.y = param2.getBounds(param2).top * this.avatar.scaleY;
               _loc6_.addChild(_loc13_);
               _loc6_.scaleX = 1 / this.avatar.scaleX;
               _loc6_.scaleY = 1 / this.avatar.scaleY;
               this._clothesLoader.setRenderQuality(_loc12_);
            }
            param1.addChild(_loc6_);
         }
      }
      
      private function colorClip(param1:Sprite, param2:Number = NaN, param3:Number = NaN) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc4_:DisplayObject = param1.getChildByName("color");
         var _loc5_:Sprite = _loc4_ == null ? param1 : _loc4_ as Sprite;
         var _loc6_:ColorTransform = this.getColorTransform(param2,param3);
         if(_loc6_ != null)
         {
            _loc5_.transform.colorTransform = _loc6_;
         }
      }
      
      private function getColorTransform(param1:Number = NaN, param2:Number = NaN) : ColorTransform
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         if(!isNaN(param1) && isNaN(param2))
         {
            _loc3_ = ((param1 & 0xFF0000) >> 16) / 255;
            _loc4_ = ((param1 & 0xFF00) >> 8) / 255;
            _loc5_ = (param1 & 0xFF) / 255;
            return new ColorTransform(_loc3_,_loc4_,_loc5_,1,0,0,0);
         }
         if(!isNaN(param1) && !isNaN(param2))
         {
            _loc6_ = (param1 & 0xFF0000) >> 16;
            _loc7_ = (param1 & 0xFF00) >> 8;
            _loc8_ = param1 & 0xFF;
            _loc9_ = (param2 & 0xFF0000) >> 16;
            _loc10_ = (param2 & 0xFF00) >> 8;
            _loc11_ = param2 & 0xFF;
            _loc12_ = (_loc6_ - _loc9_) / 255;
            _loc13_ = (_loc7_ - _loc10_) / 255;
            _loc14_ = (_loc8_ - _loc11_) / 255;
            return new ColorTransform(_loc12_,_loc13_,_loc14_,1,_loc9_,_loc10_,_loc11_,0);
         }
         return null;
      }
      
      private function getContainerClip(param1:String, param2:MovieClip) : MovieClip
      {
         if(param2 == null)
         {
            return null;
         }
         var _loc3_:Number = param1.indexOf(".",0);
         if(_loc3_ == -1)
         {
            return param2.getChildByName(param1) as MovieClip;
         }
         var _loc4_:String = param1.substring(0,_loc3_);
         var _loc5_:String = param1.substring(_loc3_ + 1,param1.length);
         return this.getContainerClip(_loc5_,param2.getChildByName(_loc4_) as MovieClip);
      }
      
      public function getFormattedClothingList(param1:Boolean = false) : Object
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:* = undefined;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         if(param1)
         {
            _loc2_ = new Object();
            _loc3_ = new Object();
            for(_loc4_ in this.categoryToIDMapping)
            {
               _loc5_ = this.categoryToIDMapping[_loc4_];
               if(!(_loc5_ == null || _loc5_.itemId == null))
               {
                  _loc6_ = _loc4_.indexOf("_temp");
                  if(_loc6_ > 0)
                  {
                     _loc3_[_loc4_.substring(0,_loc6_)] = _loc5_.playerItemId;
                  }
                  else if(_loc5_.rental)
                  {
                     _loc3_[_loc4_] = _loc5_.playerItemId;
                  }
                  else
                  {
                     _loc2_[_loc4_] = this.categoryToIDMapping[_loc4_].itemId;
                  }
               }
            }
            if(_loc2_["body"] == null)
            {
               _loc2_["body"] = {"itemId":this.avatar.getGender()};
            }
            return {
               "player_data":_loc2_,
               "tempAppearanceItems":_loc3_
            };
         }
         _loc7_ = MyLifeUtils.cloneObject(this.categoryToIDMapping);
         for each(_loc8_ in _loc7_)
         {
            _loc8_["asset"] = null;
            delete _loc8_["asset"];
         }
         if(_loc7_["body"] == null)
         {
            _loc7_["body"] = {"itemId":this.avatar.getGender()};
         }
         return _loc7_;
      }
      
      public function removeClothingItem(param1:Number) : void
      {
         var _loc4_:Object = null;
         var _loc6_:Object = null;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:MovieClip = null;
         var _loc11_:MovieClip = null;
         var _loc12_:Boolean = false;
         var _loc13_:Sprite = null;
         var _loc14_:String = null;
         var _loc2_:Array = this.clothingList[param1];
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Object = {};
         var _loc5_:int = 0;
         while(_loc5_ < _loc2_.length)
         {
            _loc6_ = _loc2_[_loc5_];
            _loc7_ = this.splitClassNameIntoPartNameAndDirection(_loc6_.className);
            _loc8_ = _loc7_[0];
            _loc9_ = _loc7_[1];
            _loc10_ = _loc9_ == "Front" ? this.avatar.avatarFrontClip : this.avatar.avatarBackClip;
            _loc11_ = this.getContainerClip(_loc6_.containerClip,_loc10_);
            _loc12_ = false;
            if(_loc11_ != null && _loc11_.itemId == param1)
            {
               _loc11_.itemId = 0;
               DisplayObjectContainerUtils.removeChildren(_loc11_);
               _loc12_ = true;
            }
            if(_loc12_)
            {
               if(_loc4_ == null)
               {
                  _loc14_ = this.convertLabelToSaveReadyLabel(_loc8_);
                  if(this.categoryToIDMapping[_loc14_])
                  {
                     _loc4_ = this.categoryToIDMapping[_loc14_].asset;
                  }
               }
               if(_loc3_[_loc8_] == null)
               {
                  this.setCategoryIDMapping(_loc8_,null);
                  delete this.renderedPartList[_loc6_.partName];
                  if(param1 == this.skinChangeItemId)
                  {
                     this.skinChangeItemId = -1;
                     this.tempSkinFillColor = -1;
                     this.tempSkinOutlineColor = -1;
                  }
                  _loc3_[_loc8_] = _loc8_;
               }
            }
            _loc5_++;
         }
         if(Boolean(_loc4_) && _loc4_.hasOwnProperty("onRemoveItem"))
         {
            _loc4_.onRemoveItem(this.avatar);
         }
         delete this.clothingList[param1];
      }
      
      public function cleanUp() : void
      {
         this.clothingList = null;
         this.renderedPartList = null;
         this.categoryToIDMapping = null;
         this.noDeleteCategoryToIDMapping = null;
         this.avatar = null;
      }
   }
}

