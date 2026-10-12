package Classes.Avatar
{
   import Cache.Classes.UI.ZCacheUI;
   import Cache.Interfaces.IZCache;
   import Classes.AvatarStateMachine;
   import Classes.FarmGameObject;
   import Classes.FarmvilleClothingLoader;
   import Classes.util.FarmGameUtil;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.MysteryBoxBalloonDialog;
   import Display.UI;
   import Engine.Constants;
   import Engine.Helpers.Vector2;
   import Engine.Helpers.Vector3;
   import Engine.IsoMath;
   import Engine.Managers.ErrorManager;
   import Events.AvatarEvent;
   import Events.FarmGameWorldEvent;
   import Managers.FarmGameSettingsManager;
   import MyLife.Character;
   import MyLife.NPC.SimpleNPC;
   import ZQuest.Init.QuestSettingsInit;
   import com.adobe.serialization.json.JSON;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   
   public class FarmAvatar extends FarmGameObject
   {
      
      protected static const ACTION_CUSTOMIZE_AVATAR:String = "FVAVATAR_CUSTOMIZE";
      
      protected static const ML_ACTION_CUSTOMIZE_AVATAR:String = "MYLIFEAVATAR_CUSTOMIZE";
      
      private const SUPER_BURST_OVERLAY:String = "assets/effects/effect_SuperAvatar_Burst.swf";
      
      private var assetPath:String = "/embedded_assets/cursors/shadow_blob.png";
      
      public var m_selectionImage:Class = FarmAvatar_m_selectionImage;
      
      protected var m_character:Character = null;
      
      protected var m_gender:String = null;
      
      public var m_energy:int;
      
      private var m_stateMachine:AvatarStateMachine;
      
      private var m_customizationData:Object;
      
      private var m_matrix:Matrix;
      
      private var m_depthPosition:Vector3;
      
      private var m_lastScaleX:Number = 0;
      
      private var m_lastScaleY:Number = 0;
      
      private var m_avatarClothingIndicator:AvatarClothingIndicator;
      
      private var m_friend:FriendAvatar;
      
      protected var m_avatarMessagingIndicator:AvatarMessagingIndicator;
      
      protected var m_inSignPostExperiment:Boolean = false;
      
      private var m_menuInit:Boolean = false;
      
      private var m_supportedTerrains:Array = new Array(FarmGameSettingsManager.TERRAIN_LAND,FarmGameSettingsManager.TERRAIN_UNDERWATER,FarmGameSettingsManager.TERRAIN_EARTH,FarmGameSettingsManager.TERRAIN_ZEN,FarmGameSettingsManager.TERRAIN_SNOW,FarmGameSettingsManager.TERRAIN_TURTLE,FarmGameSettingsManager.TERRAIN_DREAM);
      
      private var m_isInteractingWithDecoItem:Boolean = false;
      
      private var token:DisplayObject;
      
      public function FarmAvatar(customizationData:Object = null, gender:String = "female")
      {
         super();
         if(gender == null)
         {
            gender = AvatarConfigSettings.GENDER_FEMALE;
         }
         m_objectType = Constants.WORLDOBJECT_AVATAR;
         m_typeName = "avatar";
         m_size = new Vector3(1,1,20);
         this.m_stateMachine = new AvatarStateMachine();
         this.m_collisionFlags = Constants.COLLISION_AVATAR;
         this.m_depthPosition = new Vector3();
         m_depthPriority = 1;
         if(customizationData.hasOwnProperty("gender"))
         {
            this.m_gender = customizationData["gender"];
         }
         else
         {
            this.m_gender = gender;
         }
         this.m_customizationData = customizationData == null ? {} : Global.avatarConfigSettings.getLoader().parseCustomizationData(customizationData);
         Global.worldManager.addEventListener(FarmGameWorldEvent.WORLD_LOADED,this.onWorldLoaded);
      }
      
      public static function getDefaultAvatarCustomizationData(gender:String = "female") : Object
      {
         return Global.avatarConfigSettings.getDefaultRawCustomizationData(gender);
      }
      
      public static function getGenderKeyword(gender:int) : String
      {
         var keyword:String = "";
         switch(gender)
         {
            case SimpleNPC.GENDER_MALE:
               keyword = AvatarConfigSettings.GENDER_MALE;
               break;
            case SimpleNPC.GENDER_FEMALE:
               keyword = AvatarConfigSettings.GENDER_FEMALE;
         }
         return keyword;
      }
      
      private function onWorldLoaded(event:FarmGameWorldEvent) : void
      {
         this.drawDisplayObject();
      }
      
      override public function getSaveObject() : Object
      {
         return null;
      }
      
      public function getAvatarClip() : MovieClip
      {
         return this.m_character.getAvatarClip();
      }
      
      public function resetAvatarFrontClip() : void
      {
         if(Boolean(this.getAvatarClip()) && Boolean(this.getAvatarClip().avatarFrontClip))
         {
            this.getAvatarClip().avatarFrontClip = null;
         }
      }
      
      public function resetAvatarBackClip() : void
      {
         if(Boolean(this.getAvatarClip()) && Boolean(this.getAvatarClip().avatarBackClip))
         {
            this.getAvatarClip().avatarBackClip = null;
         }
      }
      
      public function getAvatarCustomizationData() : Object
      {
         return this.m_customizationData;
      }
      
      public function getStateMachine() : AvatarStateMachine
      {
         return this.m_stateMachine;
      }
      
      public function get isInteractingWithDecoItem() : Boolean
      {
         return this.m_isInteractingWithDecoItem;
      }
      
      public function set isInteractingWithDecoItem(bool:Boolean) : void
      {
         this.m_isInteractingWithDecoItem = bool;
      }
      
      override public function createDisplayObject() : DisplayObject
      {
         var objContainer:DisplayObject = new Sprite();
         m_displayObject = objContainer;
         m_displayObject.scaleX = m_displayObject.scaleY = Global.farmGameSettingsManager.getNumber("avatarScale");
         if(this.m_character)
         {
            if(this.m_character.parent == m_displayObject)
            {
               this.m_character.parent.removeChild(this.m_character);
            }
         }
         this.m_character = new Character(new FarmvilleClothingLoader());
         this.m_character.setAvatarCustomizationData(this.m_customizationData,this.m_gender == AvatarConfigSettings.GENDER_MALE ? 2 : 1);
         this.m_customizationData = this.m_character.getAvatarCustomizationData();
         var spr:Sprite = m_displayObject as Sprite;
         spr.addChild(this.m_character);
         if(this.showClothingIndicator() && this.m_avatarClothingIndicator == null)
         {
            this.m_avatarClothingIndicator = new AvatarClothingIndicator(m_displayObject,this.m_character,this);
         }
         if(this.showMessagingIndicator())
         {
            this.m_avatarMessagingIndicator = new AvatarMessagingIndicator(m_displayObject,this.m_character,this);
         }
         if(!Global.player.avatarVisible)
         {
            this.hideAvatar();
         }
         conditionallyRedraw(true);
         return m_displayObject;
      }
      
      private function onInitComplete(event:Event) : void
      {
      }
      
      override public function getDepthSize() : Vector3
      {
         return new Vector3(0.2,0.2,0);
      }
      
      override public function getDepthPosition() : Vector3
      {
         return m_position.add(new Vector3(0.4,0.4,0));
      }
      
      override public function getDepthPositionNoClone() : Vector3
      {
         this.m_depthPosition.x = m_position.x + 0.4;
         this.m_depthPosition.y = m_position.y + 0.4;
         this.m_depthPosition.z = m_position.z;
         return this.m_depthPosition;
      }
      
      override public function drawDisplayObject() : void
      {
         var tokenSize:Vector2 = null;
         super.drawDisplayObject();
         var spr:Sprite = m_displayObject as Sprite;
         if(spr != null)
         {
            while(spr.numChildren > 0)
            {
               spr.removeChildAt(0);
            }
            if(this.isSelected())
            {
               tokenSize = new Vector2(2,2);
               this.token = new this.m_selectionImage();
               this.token.name = "token";
               if(this.m_matrix == null)
               {
                  this.m_matrix = IsoMath.generateIsoTileMatrix(this.token,tokenSize);
               }
               this.token.transform.matrix = this.m_matrix;
               this.token.x -= this.token.width / 2;
               this.token.y -= this.token.height / 2;
               spr.addChild(this.token);
            }
            if(this.m_character)
            {
               spr.addChild(this.m_character);
            }
            if(m_actionMessage)
            {
               drawActionBar();
            }
            else if(this.isSelected() || isHighlighted())
            {
               if(m_actionBar)
               {
                  m_actionBar.visible = false;
               }
            }
            else if(m_actionBar)
            {
               m_actionBar.visible = false;
            }
         }
         if(this.showClothingIndicator())
         {
            if(!this.m_avatarClothingIndicator && this.m_avatarClothingIndicator == null)
            {
               this.m_avatarClothingIndicator = new AvatarClothingIndicator(m_displayObject,this.m_character,this);
            }
            this.m_avatarClothingIndicator.drawDisplayObject();
         }
         if(this.showMessagingIndicator())
         {
            if(!this.m_avatarMessagingIndicator)
            {
               this.m_avatarMessagingIndicator = new AvatarMessagingIndicator(m_displayObject,this.m_character,this);
            }
         }
      }
      
      public function showHideShadow(bool:Boolean) : void
      {
         var spr:Sprite = null;
         var token:DisplayObject = null;
         if(m_displayObject)
         {
            spr = m_displayObject as Sprite;
            token = spr.getChildByName("token");
            if(token)
            {
               token.visible = bool;
            }
         }
      }
      
      protected function showClothingIndicator() : Boolean
      {
         return Global.player.avatarArrowIndicatorVisible && !Global.worldManager.isVisiting() && !Global.player.getSeenSessionFlag("avatarEditor") && Global.player.level >= 4;
      }
      
      protected function showMessagingIndicator() : Boolean
      {
         return false;
      }
      
      override public function updateDisplayObjectTransform() : void
      {
         super.updateDisplayObjectTransform();
         m_screenPosition = IsoMath.tilePosToPixelPos(m_position.x + 0.5,m_position.y + 0.5,0,true);
         m_displayObject.x = m_screenPosition.x;
         m_displayObject.y = m_screenPosition.y - m_position.z;
         m_screenPosition.x = m_displayObject.x;
         m_screenPosition.y = m_displayObject.y;
         m_displayObject.visible = true;
      }
      
      public function getCharacter() : Character
      {
         return this.m_character;
      }
      
      override protected function onDoneWalking() : void
      {
         super.onDoneWalking();
         this.m_character.doStop();
         Global.world.dispatchEvent(new AvatarEvent(AvatarEvent.COMPLETED,this));
         this.m_character.stop();
         this.m_character.doAvatarAction("stand",false,{"d":this.getMyLifeDirection()});
      }
      
      override protected function onWalkUpdate() : void
      {
         Global.world.dispatchEvent(new AvatarEvent(AvatarEvent.MOVED));
      }
      
      override public function walkTo(x:int, y:int, minDistance:Number = 0.1) : Boolean
      {
         var foundPath:Boolean = false;
         if(super.walkTo(x,y,minDistance))
         {
            this.m_character.doAvatarAction("walk",false,{"l":-1});
            this.updateCharacterDirection();
            foundPath = true;
         }
         return foundPath;
      }
      
      override protected function updateCharacterDirection() : void
      {
         this.m_character.changeDirection(this.getMyLifeDirection());
      }
      
      public function setPlayerAvatarDirection(direction:Number) : void
      {
         setDirection(direction);
         this.updateCharacterDirection();
      }
      
      public function getMyLifeDirection() : Number
      {
         return m_direction + (m_direction > 1 ? 0 : (m_direction % 2 == 0 ? 1 : -1));
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
      }
      
      override public function updateAnimation(delta:int) : void
      {
         this.m_stateMachine.update(delta / 1000);
         onUpdateWalk(delta);
         super.updateAnimation(delta);
      }
      
      protected function updateToolTipText() : void
      {
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         if(!Global.worldManager.isVisiting() && !Global.selectedAvatar.isInteractingWithDecoItem)
         {
            setHighlighted(true);
            this.updateToolTipText();
            this.updateAvatarIndicator();
            conditionallyRedraw(true);
         }
      }
      
      override public function onMouseOut() : void
      {
         if(!Global.worldManager.isVisiting() && !Global.selectedAvatar.isInteractingWithDecoItem)
         {
            setHighlighted(false);
            setToolTip(null);
            this.updateAvatarIndicator(false);
            conditionallyRedraw(true);
         }
      }
      
      override public function onClick() : void
      {
         var showClothingInterface:Boolean = false;
         if(Boolean(this.isSelected() && Global.selectedAvatar) && Boolean(!Global.selectedAvatar.isInteractingWithDecoItem) && !Global.worldManager.isVisiting())
         {
            if(false && Config.DEBUG_MODE)
            {
               this.showMenu();
            }
            else
            {
               showClothingInterface = true;
               if(this.m_avatarClothingIndicator != null)
               {
                  if(this.m_avatarClothingIndicator.m_xButtonHighlighted)
                  {
                     this.m_avatarClothingIndicator.closeOutIndicator();
                     showClothingInterface = false;
                  }
               }
               if(showClothingInterface)
               {
                  Global.world.displayAvatarCustomizationScreen(false);
                  if(this.showClothingIndicator())
                  {
                     Global.player.resetBackoffInterval(AvatarClothingIndicator.AVATAR_SURFACING_THROTTLE_FEATURE_NAME);
                     Global.player.setFeatureLastShown(AvatarClothingIndicator.AVATAR_SURFACING_LAST_INTERACTION_FEATURE_NAME,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
                     conditionallyRedraw(this.m_avatarClothingIndicator.removeArrowIndicator());
                  }
               }
            }
         }
         if(!Global.worldManager.isVisiting())
         {
            setHighlighted(false);
            setToolTip(null);
            this.setSelected(true);
         }
      }
      
      override public function showMenu() : void
      {
         if(!this.m_menuInit)
         {
            m_menuItems.push({
               "label":"Test World preload",
               "action":"Preload world"
            });
            m_menuItems.push({
               "label":"ZCache Prompt",
               "action":"ZCachePrompt"
            });
            m_menuItems.push({
               "label":"Test Mystery game",
               "action":"mysterygame"
            });
            m_menuItems.push({
               "label":"Test Mystery game buy more v0",
               "action":"mysterygame_0"
            });
            m_menuItems.push({
               "label":"Test Mystery game buy more v1",
               "action":"mysterygame_1"
            });
            m_menuItems.push({
               "label":"Test Extended Permissions",
               "action":"ExPermTest"
            });
            m_menuItems.push({
               "label":"Refresh Extended Permissions",
               "action":"ExPermRefresh"
            });
            m_menuItems.push({
               "label":"Request Extended Permissions",
               "action":"ExPermAsk"
            });
            m_menuItems.push({
               "label":"Quest test",
               "action":"testQuest"
            });
            m_menuItems.push({
               "label":"Default Customize Avatar",
               "action":ACTION_CUSTOMIZE_AVATAR
            });
            this.m_menuInit = true;
         }
         sortMenu();
         UI.displayMenu(m_menuItems,this.onMenuClick);
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var prompt:GenericPopup = null;
         var item:ContextMenuItem = null;
         var zCache:IZCache = null;
         var sandboxUrl:String = null;
         var zCacheUI:ZCacheUI = null;
         var c:Class = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case "ZCachePrompt":
                  zCache = GlobalZCache.instance;
                  sandboxUrl = Global.getAssetURL(Global.farmGameSettingsManager.getString("zCacheSandboxUrl"));
                  zCacheUI = new ZCacheUI(zCache,Global.stage,sandboxUrl,true,true);
                  zCacheUI.offsets = new Point(20,0);
                  if(zCacheUI)
                  {
                     zCacheUI.showPermissionsPrompt(null);
                  }
                  break;
               case ACTION_CUSTOMIZE_AVATAR:
                  Global.world.displayAvatarCustomizationScreen(false);
                  break;
               case "mysterygame":
                  MysteryBoxBalloonDialog.openDefaultMysteryGame();
                  break;
               case "mysterygame_0":
                  MysteryBoxBalloonDialog.buyMoreOverride = 0;
                  MysteryBoxBalloonDialog.openDefaultMysteryGame();
                  break;
               case "mysterygame_1":
                  MysteryBoxBalloonDialog.buyMoreOverride = 1;
                  MysteryBoxBalloonDialog.openDefaultMysteryGame();
                  break;
               case "ExPermTest":
                  Global.player.extendedPermissionState.test();
                  break;
               case "ExPermRefresh":
                  Global.player.extendedPermissionState.refreshExtendedPermissions(function(response:Object):void
                  {
                     UI.showMessage("result:" + com.adobe.serialization.json.JSON.encode(response));
                  },false);
                  break;
               case "ExPermAsk":
                  Global.player.extendedPermissionState.requestExtendedPermissions(function(response:Object):void
                  {
                     UI.showMessage("result:" + com.adobe.serialization.json.JSON.encode(response));
                  });
                  break;
               case "testQuest":
                  c = QuestSettingsInit.getInstance().getClientPredictionClass;
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      public function isSelected() : Boolean
      {
         return Global.selectedAvatar == this;
      }
      
      public function setSelected(selected:Boolean) : void
      {
         if(selected)
         {
            if(Global.selectedAvatar)
            {
               Global.selectedAvatar.setSelected(false);
            }
            if(Global.selectedAvatar != this)
            {
               Global.selectedAvatar = this;
               setDisplayObjectDirty(true);
            }
         }
         else if(Global.selectedAvatar == this)
         {
            Global.selectedAvatar = null;
            setDisplayObjectDirty(true);
         }
         conditionallyRedraw();
      }
      
      public function get gender() : int
      {
         var gender:int = this.m_character.gender;
         if(this.m_gender)
         {
            gender = this.m_gender == AvatarConfigSettings.GENDER_FEMALE ? AvatarConfigSettings.GENDER_CODE_FEMALE : AvatarConfigSettings.GENDER_CODE_MALE;
         }
         return gender;
      }
      
      public function set gender(value:int) : void
      {
         this.m_character.gender = value;
         this.m_gender = getGenderKeyword(value);
      }
      
      public function set walkSpeed(newSpeed:Number) : void
      {
         m_WalkSpeed = newSpeed;
      }
      
      public function get walkSpeed() : Number
      {
         return m_WalkSpeed;
      }
      
      override protected function getOverlayStartPos() : Point
      {
         return new Point(this.getScreenPosition().x - 30,this.getScreenPosition().y - 50);
      }
      
      override protected function getOverlayScale() : Number
      {
         return 2;
      }
      
      public function startSuperOverlay() : void
      {
         var overlayParams:Object = new Object();
         overlayParams.overlayMc = "burst_mc";
         overlayParams.scale = 0.6;
         overlayParams.offsetX = -22;
         overlayParams.offsetY = -20;
         overlayParams.startFrame = 1;
         overlayParams.noLoop = true;
         overlayParams.noReuse = true;
         overlayParams.alpha = 0.3;
         startOverlay(this.SUPER_BURST_OVERLAY,overlayParams);
      }
      
      public function hideAvatar() : void
      {
         if(m_displayObject)
         {
            m_displayObject.visible = false;
            if(m_displayObject.scaleX > 0 && m_displayObject.scaleY > 0)
            {
               this.m_lastScaleX = m_displayObject.scaleX;
               this.m_lastScaleY = m_displayObject.scaleY;
               m_displayObject.scaleX = m_displayObject.scaleY = 0;
            }
         }
      }
      
      public function showAvatar() : void
      {
         if(m_displayObject)
         {
            m_displayObject.visible = true;
            if(this.m_lastScaleX > 0)
            {
               m_displayObject.scaleX = this.m_lastScaleX;
            }
            if(this.m_lastScaleY > 0)
            {
               m_displayObject.scaleY = this.m_lastScaleY;
            }
         }
      }
      
      public function get lastScaleX() : Number
      {
         var res:Number = 0;
         if(m_displayObject)
         {
            res = m_displayObject.scaleX;
         }
         return res;
      }
      
      public function get lastScaleY() : Number
      {
         var res:Number = 0;
         if(m_displayObject)
         {
            res = m_displayObject.scaleY;
         }
         return res;
      }
      
      public function setAvatarCustomizationData(customizationData:Object, gender:int = 0) : void
      {
         this.m_character.setAvatarCustomizationData(customizationData,gender);
         this.m_customizationData = this.m_character.getAvatarCustomizationData();
         this.gender = gender;
         AvatarManager.saveAvatar(Global.player);
         Global.ui.m_friendBar.updatePlayerAvatar(Global.player.uid,this.m_customizationData,this.m_character.gender);
      }
      
      public function equipItem(avatarItem:Object) : void
      {
         if(avatarItem is AvatarItem)
         {
            avatarItem = (avatarItem as AvatarItem).toRawObject();
         }
         this.m_character.equipItem(avatarItem,this.onItemEquipped);
      }
      
      private function onItemEquipped() : void
      {
         Global.player.avatar.setAvatarCustomizationData(this.m_character.getAvatarCustomizationData(),this.m_character.gender);
         AvatarManager.saveAvatar(Global.player);
         Global.ui.m_friendBar.updatePlayerAvatar(Global.player.uid,this.m_character.getAvatarCustomizationData(),this.m_character.gender);
      }
      
      protected function updateAvatarIndicator(show:Boolean = true) : void
      {
         if(Global.player.avatarArrowIndicatorVisible)
         {
            if(this.m_avatarClothingIndicator)
            {
               this.m_avatarClothingIndicator.showRolloverText(show);
            }
            if(this.m_avatarMessagingIndicator)
            {
               this.m_avatarMessagingIndicator.showRolloverEffect(show);
            }
         }
      }
      
      public function getSupportedTerrainCodes() : Array
      {
         var terrainArray:Array = null;
         var i:int = 0;
         var terrainCodes:Array = new Array();
         for(var index:int = 0; index < this.m_supportedTerrains.length; index++)
         {
            terrainArray = Global.farmGameSettingsManager.getTerrainCodes(this.m_supportedTerrains[index]);
            if(terrainArray != null)
            {
               for(i = 0; i < terrainArray.length; i++)
               {
                  if(terrainCodes.indexOf(terrainArray[i]) == -1)
                  {
                     terrainCodes.push(terrainArray[i]);
                  }
               }
            }
            else
            {
               ErrorManager.addError("Terrain name " + this.m_supportedTerrains[index] + " not found in game settings.");
            }
         }
         return terrainCodes;
      }
   }
}

