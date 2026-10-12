package Classes
{
   import AvatarMode.AMHarvest;
   import AvatarMode.AMPet;
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.ClickTrackingConstants;
   import Classes.Constants.CollectionsConstants;
   import Classes.Constants.Experiments;
   import Classes.Constants.ToasterIconPaths;
   import Classes.NeighborActions.NeighborActionConstants;
   import Classes.UGC.UGCDragonBreeding;
   import Classes.ZItem.AnimalItem;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.instagrow.InstagrowUtils;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Classes.World;
   import Engine.Constants;
   import Engine.Helpers.Vector3;
   import Engine.Managers.SoundManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import GameMode.GMAirplaneFly;
   import Managers.CollectionsManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureBuildingGiftContentDataManager;
   import Managers.FeatureBuildingSurfacingManager;
   import Managers.InstagrowHelper;
   import Managers.ItemMembershipManager;
   import Managers.NPCManager;
   import Managers.RetentionMasterManager;
   import Managers.ToasterManager;
   import Transactions.TAnimalTransform;
   import Transactions.TMove;
   import Widgets.Windows.BuildingSurfaceWindow;
   import Widgets.Windows.Mastery.MasteryWindow;
   import Widgets.Windows.TwoIconTitleToasterWindow;
   import com.adobe.serialization.json.JSON;
   import flash.display.BlendMode;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.utils.getQualifiedClassName;
   
   public class Animal extends SimpleHarvestableResource implements IRotatable
   {
      
      protected static var s_colorTransformGhost:ColorTransform;
      
      public static const STATE_FRONT_IDLE:String = "frt_idle";
      
      public static const STATE_FRONT_CYCLE:String = "frt_cycle";
      
      public static const STATE_BACK_IDLE:String = "bk_idle";
      
      public static const STATE_BACK_CYCLE:String = "bk_cycle";
      
      private static const ANIMAL:String = "animal";
      
      protected static var s_colorTime:Number = 10;
      
      private static const FARM_HAND_ITEM_NAME:String = "consume_farm_hands";
      
      private static const APPLY_GROW:String = "applyInstantGrow";
      
      protected static const STATE_BARE:String = "bare";
      
      protected static const STATE_RIPE:String = "ripe";
      
      protected static var m_globalAllowWander:Boolean = true;
      
      protected static var m_isWandering:Boolean = false;
      
      protected static var m_wanderingObject:Animal = null;
      
      protected static var m_lastWanderTime:int = 0;
      
      protected var m_soundTime:Number = 0;
      
      private const ANIMAL_PET:String = "animal_sound";
      
      private const TRANSFORM_OBJECT:String = "transformObject";
      
      protected var m_wanderTime:Number = 0;
      
      protected var m_wanderStartPos:Vector3 = null;
      
      protected var m_wanderEndPos:Vector3 = null;
      
      protected var m_wanderStartState:String = null;
      
      protected var m_wanderPlaceHolder:Animal = null;
      
      protected var m_allowWander:Boolean = true;
      
      protected const ALLOW_WANDER:String = "allowWander";
      
      protected const DISALLOW_WANDER:String = "disallowWander";
      
      protected var m_hasHarvestAction:Boolean = true;
      
      protected var m_animalState:String = "";
      
      protected var m_animationStartTime:Number = 0;
      
      private var m_menuActionItemXML:Object;
      
      protected var m_showExtraMenuItems:Boolean = true;
      
      private var m_animalTypes:Array;
      
      public function Animal(animalType:String = null)
      {
         var hasDataSource:Boolean = false;
         var itemXML:XML = null;
         this.m_menuActionItemXML = {};
         this.m_animalTypes = [ShareableHarvestAnimal,PregnantSow,MutableAnimal,DoghouseAnimal,GrowableBaby,CashGrowableBaby,ItemGrowableBaby,RandomItemGrowableBaby,UGCAnimal,UGCDragonBreeding,GrowableAnimal,EvolutionAnimal,MutableDragon,FestivalOfColorAnimal];
         super(animalType);
         m_objectType = WorldObjectTypes.ANIMAL;
         this.generateSoundTime();
         this.generateWanderTime();
         m_typeName = ANIMAL;
         m_direction = Constants.DIRECTION_SE;
         m_surfacingKeyword = FeatureBuildingSurfacingManager.ANIMAL_SURFACING_KEYWORD;
         if(m_item != null)
         {
            hasDataSource = false;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               hasDataSource = true;
            }
            else
            {
               itemXML = m_item.xml;
               hasDataSource = itemXML != null;
            }
            if(hasDataSource && (m_item as HarvestableItem).hasMastery)
            {
               m_arrowArt = EmbeddedArt.harvestArrowAnimalMastery;
            }
         }
      }
      
      public static function stopAllWandering() : void
      {
         m_globalAllowWander = false;
         if(m_wanderingObject != null)
         {
            m_wanderingObject.abortWander();
         }
      }
      
      public static function allowWander() : void
      {
         m_globalAllowWander = true;
      }
      
      override public function isUsingPerPixelPick() : Boolean
      {
         return true;
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(state == null)
         {
            setState(STATE_BARE);
         }
         if(plantTime == 0 || isNaN(plantTime))
         {
            plantTime = 1;
         }
         m_direction = data.direction;
         this.m_allowWander = data.canWander;
      }
      
      override protected function getCurrentImage() : ItemImage
      {
         var imageName:String = null;
         var disallowAltAnimation:Boolean = false;
         this.ghost(false);
         var image:ItemImage = null;
         if(m_item != null)
         {
            if(this.m_altGraphic != "")
            {
               switch(m_altGraphic)
               {
                  case "ghost":
                     this.ghost(true);
                     break;
                  default:
                     m_overlayXML = Global.farmGameSettingsManager.getOverlayByName(this.m_altGraphic);
                     conditionallyAttachOverlay();
               }
            }
            if(this.m_hasHarvestAction || this.hasTransformAction())
            {
               switch(state)
               {
                  case STATE_BARE:
                     m_filters = [];
                     m_arrow = null;
                     break;
                  case STATE_RIPE:
                     m_filters = [];
                     if(m_arrow == null && !NPCManager.getInstance().isVisitingNPC && isHarvestable())
                     {
                        m_arrow = generateHarvestArrow();
                     }
               }
               setHighlighted(isHighlighted());
            }
            imageName = this.getCurrentImageName();
            imageName = postProcessImageName(imageName);
            disallowAltAnimation = !(m_outer is World);
            image = this.getCachedImage(imageName,disallowAltAnimation);
            if(!image)
            {
               image = this.getCachedImage(imageName,disallowAltAnimation);
            }
         }
         return image;
      }
      
      override public function getCurrentImageName() : String
      {
         var progression:IMapResourceImageProgression = null;
         var imageName:String = "";
         if(m_item.imageProgressionClassName != null)
         {
            progression = getImageProgression();
            if(progression != null)
            {
               imageName = progression.getCurrentImageName();
            }
         }
         else
         {
            if(m_item.allowAnimalTypeWander)
            {
               if(state == "swim_idle")
               {
                  imageName = "swim_idle";
               }
               else if(m_wanderingObject == this)
               {
                  if(m_direction == Constants.DIRECTION_SE || m_direction == Constants.DIRECTION_SW)
                  {
                     imageName = STATE_FRONT_CYCLE;
                  }
                  else
                  {
                     imageName = STATE_BACK_CYCLE;
                  }
               }
               else if(m_direction == Constants.DIRECTION_SE || m_direction == Constants.DIRECTION_SW)
               {
                  imageName = STATE_FRONT_IDLE;
               }
               else
               {
                  imageName = STATE_BACK_IDLE;
               }
            }
            else
            {
               imageName = STATE_FRONT_IDLE;
            }
            if(m_pattern != "")
            {
               imageName = m_pattern + "_" + imageName;
            }
            if(!m_item.displayLoader.hasImageNameDefined(imageName))
            {
               if(imageName == STATE_BACK_CYCLE)
               {
                  imageName = STATE_FRONT_CYCLE;
               }
               if(imageName == STATE_BACK_IDLE)
               {
                  imageName = STATE_FRONT_IDLE;
               }
            }
         }
         return imageName;
      }
      
      override protected function getDisplayHorizontalOffset() : Number
      {
         var xOffset:Number = 0;
         if(m_direction == Constants.DIRECTION_NE || m_direction == Constants.DIRECTION_SW)
         {
            if(m_displayObject != null && m_itemImage != null && Boolean(m_itemImage.boxWidth))
            {
               m_displayObject.scaleX = -m_displayObject.scaleX;
               xOffset = m_itemImage.boxWidth * getImageScaleFactor();
            }
         }
         return xOffset;
      }
      
      private function ghost(turnOn:Boolean) : void
      {
         if(s_colorTransformGhost == null)
         {
            s_colorTransformGhost = new ColorTransform(0.9,0.9,0.5,0.75,20,20,20);
         }
         if(turnOn && m_displayObject.blendMode == BlendMode.NORMAL)
         {
            m_displayObject.transform.colorTransform = s_colorTransformGhost;
            m_displayObject.blendMode = BlendMode.SCREEN;
         }
         else if(!turnOn && m_displayObject.blendMode != BlendMode.NORMAL)
         {
            m_displayObject.transform.colorTransform = new ColorTransform();
            m_displayObject.blendMode = BlendMode.NORMAL;
         }
      }
      
      private function resetColorTransform() : void
      {
         if(s_colorTransformGhost == null)
         {
            s_colorTransformGhost = new ColorTransform(0.9,0.9,0.5,0.75,20,20,20);
         }
         s_colorTransformGhost.redMultiplier = Math.random();
         s_colorTransformGhost.greenMultiplier = Math.random();
         s_colorTransformGhost.blueMultiplier = Math.random();
         s_colorTransformGhost.alphaMultiplier = 0.75;
         s_colorTime = Global.farmGameSettingsManager.getInt("ghostAnimalColorFreqency",50);
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         if(!isNaN(delta))
         {
            if(!SoundManager.isMuted())
            {
               this.m_soundTime -= delta;
               if(this.m_soundTime <= 0)
               {
                  this.playRandomSound();
                  this.generateSoundTime();
               }
               else if(isNaN(this.m_soundTime))
               {
                  this.generateSoundTime();
               }
            }
            if(m_globalAllowWander && this.m_allowWander)
            {
               this.m_wanderTime -= delta;
               if(this.m_wanderTime <= 0)
               {
                  this.wander();
                  this.generateWanderTime();
               }
               else if(isNaN(this.m_wanderTime))
               {
                  this.generateWanderTime();
               }
            }
            if(Global.animationState == Global.ANIMATION_STATE_PLAY)
            {
               s_colorTime -= delta;
               if(s_colorTime <= 0)
               {
                  this.resetColorTransform();
               }
               if(m_altGraphic == "ghost")
               {
                  if(m_displayObject.transform.colorTransform != Animal.s_colorTransformGhost)
                  {
                     m_displayObject.transform.colorTransform = Animal.s_colorTransformGhost;
                  }
                  if(Math.random() > 0.3)
                  {
                     m_displayObject.alpha = 1;
                  }
               }
            }
         }
      }
      
      override public function updateAnimation(delta:int) : void
      {
         if(this.m_outer)
         {
            onUpdateWalk(delta);
         }
         else
         {
            FarmStatsManager.featureSample("errors","world_action_failure","move","flash_animal_no_outer");
         }
         super.updateAnimation(delta);
      }
      
      override protected function determineState(delta:Number) : void
      {
         if((this.m_hasHarvestAction || this.hasTransformAction()) && isHarvestable() && state == STATE_BARE)
         {
            setState(STATE_RIPE);
         }
      }
      
      protected function generateSoundTime() : void
      {
         this.m_soundTime = Utilities.randBetween(Global.farmGameSettingsManager.getNumber("animalSoundMinDelaySeconds"),Global.farmGameSettingsManager.getNumber("animalSoundMaxDelaySeconds"));
      }
      
      protected function generateWanderTime() : void
      {
         if(GlobalEngine.getFlashVar("animalsWalking") != null)
         {
            this.m_wanderTime = Utilities.randBetween(Global.farmGameSettingsManager.getNumber("animalWanderMinDelaySeconds"),Global.farmGameSettingsManager.getNumber("animalWanderMaxDelaySeconds"));
         }
         else
         {
            this.m_wanderTime = 1000000;
         }
      }
      
      public function playRandomSound() : void
      {
         var soundArr:Array = null;
         var rand:int = 0;
         var soundUrl:String = null;
         var soundId:String = null;
         if(!SoundManager.isMuted())
         {
            if(m_item == null)
            {
               return;
            }
            soundArr = m_item.sounds;
            if(soundArr.length > 0)
            {
               rand = Math.round(Math.random() * (soundArr.length - 1));
               if(rand < soundArr.length)
               {
                  soundUrl = soundArr[rand];
                  soundId = m_item.name + rand;
                  SoundManager.addSound(soundId,Global.getAssetURL(soundUrl));
                  SoundManager.playSound(soundId);
               }
            }
         }
      }
      
      override protected function onDoneWalking() : void
      {
         if(m_isWandering && m_wanderingObject == this)
         {
            detach();
            this.m_wanderPlaceHolder.detach();
            m_wanderingObject = null;
            this.syncWalkPosition(this.m_wanderEndPos);
            setPosition(this.m_wanderEndPos.x,this.m_wanderEndPos.y,this.m_wanderEndPos.z);
            this.m_wanderEndPos = null;
            m_isWandering = false;
            attach();
            reloadImage();
         }
         this.generateWanderTime();
      }
      
      override protected function updateCharacterDirection() : void
      {
         reloadImage();
      }
      
      public function isPlaced() : Boolean
      {
         return state == STATE_BARE;
      }
      
      public function isGrown() : Boolean
      {
         return state == STATE_RIPE;
      }
      
      public function hasSound() : Boolean
      {
         var result:Boolean = false;
         if(m_item)
         {
            result = m_item.sounds.length > 0;
         }
         return result;
      }
      
      override public function showMenu() : void
      {
         if(m_wanderingObject != this && !inQueue())
         {
            this.generateMenuItems();
            this.abortWander();
            m_globalAllowWander = false;
            super.showMenu();
            FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,"context_menu_open","animal","","","User opens context menu from animal");
         }
         else
         {
            displayStatus(ZLocUtils.t("FarmGame","AnimalBusy"));
         }
      }
      
      override protected function canShowSellMenuItem() : Boolean
      {
         return Global.player.level >= Global.farmGameSettingsManager.getInt("sellLockLevel");
      }
      
      protected function generateMenuItems() : void
      {
         var actionName:String = null;
         var isValidAction:Boolean = false;
         var menuItemsArr:Array = null;
         var itemDS:BaseDataSource = null;
         var menuItems:XMLList = null;
         var item:XML = null;
         m_menuItems = [];
         if(this.m_showExtraMenuItems)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               menuItemsArr = this.m_item.getArrayFromDataSource("extraMenuItem");
               for each(itemDS in menuItemsArr)
               {
                  actionName = itemDS.toString();
                  if(actionName.length > 0)
                  {
                     isValidAction = true;
                     switch(actionName)
                     {
                        case CHANGE_NAME:
                           if(!getMetadata())
                           {
                              isValidAction = false;
                           }
                     }
                     if(isValidAction)
                     {
                        m_menuItems.push({
                           "label":ZLocUtils.t("Items",itemDS.getString("label")),
                           "action":actionName
                        });
                     }
                  }
               }
            }
            else
            {
               menuItems = this.m_item.xml.child("extraMenuItem");
               for each(item in menuItems)
               {
                  if(item.children()[0].toString().length > 0)
                  {
                     actionName = item.children()[0].toString();
                     isValidAction = true;
                     switch(actionName)
                     {
                        case CHANGE_NAME:
                           if(!getMetadata())
                           {
                              isValidAction = false;
                           }
                     }
                     if(isValidAction)
                     {
                        m_menuItems.push({
                           "label":ZLocUtils.t("Items",item.@label),
                           "action":actionName
                        });
                     }
                  }
               }
            }
         }
         m_menuItems.push({
            "label":ZLocUtils.t("FarmGame","Move"),
            "action":MOVE_OBJECT
         });
         if(allowDelete() && this.canShowSellMenuItem())
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","Sell"),
               "action":SELL_OBJECT
            });
         }
         if(InstagrowHelper.playerCanSeeFeature() && this.shouldShowInstagrowMenuOption())
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","ApplyInstantGrow"),
               "action":APPLY_GROW
            });
         }
         var action:String = this.getItem().action;
         var actionText:String = this.getItem().actionText;
         switch(action)
         {
            case "harvest":
               if(Boolean(actionText != "") && Boolean(Global.selectedAvatar) && isHarvestable())
               {
                  m_menuItems.push({
                     "label":ZLocUtils.t("Items",actionText + "_friendlyName"),
                     "action":HARVEST_OBJECT
                  });
               }
               break;
            case "transform":
               if(Boolean(Global.selectedAvatar) && isHarvestable())
               {
                  m_menuItems.push({
                     "label":ZLocUtils.t("Items","TransformAnimal"),
                     "action":this.TRANSFORM_OBJECT
                  });
               }
         }
         if(this.getItem().allowAnimalTypeWander && !Global.worldManager.isVisiting())
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","Rotate"),
               "action":ROTATE_OBJECT
            });
         }
         if(this.hasSound() && m_altGraphic == "")
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","Pet"),
               "action":this.ANIMAL_PET
            });
         }
      }
      
      public function shouldShowInstagrowMenuOption() : Boolean
      {
         return true;
      }
      
      override public function onClick() : void
      {
         onMouseOut();
         if(isHarvestable() && Global.player.shouldDisplayMassHarvesterToaster(Player.FARMHAND_ITEM_NAME,Animal))
         {
            Global.player.displayMassHarvesterToaster(Player.FARMHAND_ITEM_NAME);
         }
         else if(!hasValidId())
         {
            showObjectBusy();
         }
         else if(Boolean(!Global.worldManager.isVisiting() && Global.selectedAvatar && m_wanderingObject != this && !inQueue()) && Boolean(this.getItem().action == "harvest") && isHarvestable())
         {
            Global.selectedAvatar.getStateMachine().addState(new AMHarvest(Global.selectedAvatar,this),true);
         }
         else
         {
            super.onClick();
         }
      }
      
      private function onWindowClose(event:GenericPopupEvent) : void
      {
         var titleMsg:String = null;
         var msg:String = null;
         var acceptText:String = null;
         titleMsg = ZLocUtils.t("Dialogs","Consumable_Harvest_Animals_Surfacing_Toaster_Title");
         msg = ZLocUtils.t("Dialogs","Consumable_Harvest_Animals_Surfacing_Toaster_Use_Farmhand_Body");
         acceptText = ZLocUtils.t("Dialogs","Consumable_Harvest_Animals_Surfacing_Toaster_Has_No_Farmhand_Button");
         ToasterManager.getInstance().add(new TwoIconTitleToasterWindow(titleMsg,msg,ToasterIconPaths.FARMHAND_ICON,"",ToasterIconPaths.DIALOG_ASSET,0.5,0.5,new Point(15,8),new Point(15,0),null,false,false,null,null,acceptText));
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var clickedApplyGrow:Boolean = false;
         var message:String = null;
         var dialog:GenericPopup = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            if(m_wanderingObject != this)
            {
               this.generateWanderTime();
               clickedApplyGrow = false;
               switch(item.action)
               {
                  case this.ANIMAL_PET:
                     this.petAnimal();
                     this.generateSoundTime();
                     break;
                  case this.ALLOW_WANDER:
                     this.m_allowWander = true;
                     this.syncChanges();
                     m_globalAllowWander = true;
                     break;
                  case APPLY_GROW:
                     clickedApplyGrow = true;
                     FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,"context_menu_click","animal",InstagrowUtils.INSTA_GROW_COUNTER,"","User opens context menu from animal, clicks on instant_grow");
                     if(Global.world.addGameMode(new GMAirplaneFly(),true) == false)
                     {
                        message = ZLocUtils.t("Dialogs","InstantGrow_OnlyOnePlaneAtATime");
                        dialog = new GenericPopup(message,GenericPopup.TYPE_OK);
                        UI.displayPopup(dialog);
                     }
                     break;
                  case this.DISALLOW_WANDER:
                     this.m_allowWander = false;
                     this.syncChanges();
                     m_globalAllowWander = true;
                     break;
                  case ROTATE_OBJECT:
                     this.rotate();
                     this.syncChanges();
                     break;
                  case this.TRANSFORM_OBJECT:
                     this.transform();
                     this.m_allowWander = false;
                     m_globalAllowWander = true;
                     break;
                  case SELL_OBJECT:
                     this.m_allowWander = false;
                     m_globalAllowWander = true;
                     super.onMenuClick(event);
                     break;
                  default:
                     m_globalAllowWander = false;
                     super.onMenuClick(event);
               }
               if(!clickedApplyGrow)
               {
                  FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,"context_menu_click","animal","all_other_options","","User opens context menu from animal, clicks on all_other_options");
               }
            }
         }
      }
      
      override protected function getMasteryWindowType() : String
      {
         return MasteryWindow.TYPE_ANIMAL;
      }
      
      override public function canBeClickedOnVisit() : Boolean
      {
         return this.isHarvestable() && VisitorManager.getInstance().canPerformAction(this,NeighborActionConstants.LIMIT_TYPE_FARM_ACTION);
      }
      
      public function canRotate() : Boolean
      {
         return getItem().allowAnimalTypeWander;
      }
      
      public function rotate(fromMoveTool:Boolean = true) : void
      {
         ++m_direction;
         if(m_direction >= Constants.ROTATION_MAX)
         {
            m_direction = 0;
         }
         reloadImage();
         m_globalAllowWander = true;
         FarmStatsManager.count(ClickTrackingConstants.CLICK_STATS_COUNTER,"animal","rotate",m_direction.toString());
      }
      
      public function syncRotationChange() : void
      {
         this.syncChanges();
      }
      
      override public function setItem(item:FarmItem) : void
      {
         var setHasHarvest:Boolean = item != m_item;
         super.setItem(item);
         if(setHasHarvest)
         {
            this.m_hasHarvestAction = this.hasHarvestAction();
         }
      }
      
      override public function move() : void
      {
         m_globalAllowWander = false;
         if(m_wanderingObject)
         {
            m_wanderingObject.abortWander();
         }
         super.move();
      }
      
      public function hasHarvestAction() : Boolean
      {
         var item:FarmItem = getItem();
         var result:Boolean = false;
         if(item)
         {
            result = item.action == "harvest";
         }
         return result;
      }
      
      public function hasTransformAction() : Boolean
      {
         var item:FarmItem = getItem();
         var result:Boolean = false;
         if(item)
         {
            result = item.action == "transform";
         }
         return result;
      }
      
      override public function doHarvestDropOff(avatar:FarmAvatar, showStatus:Boolean = true) : Object
      {
         if(!SoundManager.isMuted())
         {
            this.playRandomSound();
            this.generateSoundTime();
         }
         return super.doHarvestDropOff(avatar,showStatus);
      }
      
      override protected function buildTooltipText() : String
      {
         var hasHarvestAction:Boolean = false;
         var hasTransformAction:Boolean = false;
         var harvestTimeVariant:int = 0;
         var actionText:String = null;
         var growPercentage:int = 0;
         var toolTip:String = null;
         if(!Global.worldManager.isVisiting())
         {
            hasHarvestAction = this.hasHarvestAction();
            hasTransformAction = this.hasTransformAction();
            if(hasHarvestAction || hasTransformAction)
            {
               switch(state)
               {
                  case STATE_RIPE:
                     if(hasHarvestAction && isHarvestable())
                     {
                        toolTip = "";
                        actionText = this.getItem().actionText;
                        if(actionText != "")
                        {
                           toolTip = ZLocUtils.t_pk("Items:" + actionText + "_friendlyName") + "\n";
                        }
                        toolTip += ZLocUtils.t("FarmGame","HarvestableAnimal",{"item":ZLocUtils.tk_pk(m_item.friendlyName)});
                     }
                     else if(hasTransformAction)
                     {
                        toolTip = ZLocUtils.t("FarmGame","TransformAnimal",{"item":ZLocUtils.tk_pk(m_item.friendlyName)});
                     }
                     break;
                  case STATE_BARE:
                     harvestTimeVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HARVEST_TIME_2);
                     if(RetentionMasterManager.inMasterExperiment() && (harvestTimeVariant == 2 || harvestTimeVariant == 4))
                     {
                        toolTip = getHarvestTimeText();
                     }
                     else
                     {
                        growPercentage = getGrowPercentage();
                        toolTip = ZLocUtils.t("FarmGame","NormalAnimal",{
                           "item":ZLocUtils.tk_pk(m_item.friendlyName),
                           "quantity":growPercentage
                        });
                     }
                     if(getQualifiedClassName(Global.world.getTopGameMode()) == "GameMode::GMDefault" && InstagrowHelper.playerCanSeeFeature())
                     {
                        toolTip += "\n" + ZLocUtils.t("FarmGame","ApplyInstantGrowHint");
                     }
               }
            }
            else
            {
               toolTip = m_item.friendlyTitle;
            }
         }
         else
         {
            toolTip = m_item.friendlyTitle;
            if(this.isHarvestableByNeighbors() && state == STATE_RIPE && VisitorManager.getInstance().canPerformAction(this,NeighborActionConstants.LIMIT_TYPE_FARM_ACTION))
            {
               toolTip = ZLocUtils.t("FarmGame","AskToHarvest");
            }
         }
         return toolTip;
      }
      
      override public function getHarvestText() : String
      {
         return ZLocUtils.t("FarmGame","Collecting");
      }
      
      protected function createPlaceholder() : Animal
      {
         var clone:Animal = new Animal();
         clone.m_size = m_size;
         clone.m_outer = m_outer;
         clone.m_visible = false;
         return clone;
      }
      
      private function syncWalkPosition(endPosition:Vector3) : void
      {
         var mapObject:MapResource = this as MapResource;
         mapObject.setPosition(this.m_wanderStartPos.x,this.m_wanderStartPos.y,this.m_wanderStartPos.z);
         var params:Object = new Object();
         params.x = Math.round(endPosition.x);
         params.y = Math.round(endPosition.y);
         params.direction = m_direction;
         params.canWander = this.m_allowWander;
         params.state = mapObject.getState();
         params.localId = Global.player.snUser.uid.toString();
         params.worldSize = Global.world.getNumObjects();
         params.functionFrom = "syncWalkPosition";
         params.startX = Math.round(this.m_wanderStartPos.x);
         params.startY = Math.round(this.m_wanderStartPos.y);
         addTransaction(new TMove(mapObject,params));
         mapObject.setPosition(endPosition.x,endPosition.y,endPosition.z);
      }
      
      private function syncChanges() : void
      {
         var params:Object = new Object();
         params.x = Math.round(getPosition().x);
         params.y = Math.round(getPosition().y);
         params.direction = m_direction;
         params.canWander = this.m_allowWander;
         params.state = getState();
         params.localId = Global.player.snUser.uid.toString();
         params.worldSize = Global.world.getNumObjects();
         params.functionFrom = "syncChanges";
         addTransaction(new TMove(this,params));
      }
      
      override public function addTMoveParams(params:Object) : Object
      {
         params.direction = m_direction;
         params.canWander = this.m_allowWander;
         return params;
      }
      
      protected function wander() : void
      {
         var localAllowWander:Boolean = false;
         var dist:Number = NaN;
         var walkPos:Vector3 = null;
         var objSize:Vector3 = null;
         var positionValid:Boolean = false;
         if(Global.ui.mouseEnabled && m_globalAllowWander && this.m_allowWander && !m_isWandering && !m_isInHarvestQueue && m_attachPosition != null && getId() > 0)
         {
            localAllowWander = false;
            if(GlobalEngine.currentTime - m_lastWanderTime > Global.farmGameSettingsManager.getInt("animalMinTicksBetweenWander"))
            {
               if(GlobalEngine.currentTime - Global.lastInputTick < Global.farmGameSettingsManager.getInt("animalWanderIdle"))
               {
                  if(Global.appActive && !Global.worldManager.isVisiting())
                  {
                     if(getItem() != null)
                     {
                        localAllowWander = getItem().allowAnimalTypeWander;
                     }
                     else
                     {
                        localAllowWander = true;
                     }
                  }
               }
            }
            if(localAllowWander)
            {
               dist = Global.farmGameSettingsManager.getNumber("animalWanderMaxDistance");
               walkPos = getPosition().clone();
               walkPos.x += Utilities.randBetween(-dist,dist);
               walkPos.y += Utilities.randBetween(-dist,dist);
               objSize = getSize();
               walkPos.x = Math.round(Utilities.clamp(walkPos.x,0,Global.world.getGridWidth() - objSize.x));
               walkPos.y = Math.round(Utilities.clamp(walkPos.y,0,Global.world.getGridHeight() - objSize.y));
               positionValid = !Global.world.checkCollision(walkPos.x,walkPos.y,walkPos.x + objSize.x,walkPos.y + objSize.y,[this],null,Constants.WORLDOBJECT_ALL,null,false);
               if(positionValid && walkPos != getPosition())
               {
                  this.m_wanderStartPos = getPosition();
                  this.m_wanderStartState = getState();
                  m_WalkSpeed = this.getItem().wanderSpeed;
                  if(m_WalkSpeed <= 0)
                  {
                     m_WalkSpeed = Global.farmGameSettingsManager.getNumber("animalWanderSpeed");
                  }
                  m_isWandering = walkTo(walkPos.x,walkPos.y,0.1);
                  if(m_isWandering)
                  {
                     this.m_wanderEndPos = new Vector3(walkPos.x,walkPos.y,walkPos.z);
                     m_wanderingObject = this;
                     this.m_wanderPlaceHolder = this.createPlaceholder();
                     if(this.m_wanderPlaceHolder)
                     {
                        this.m_wanderPlaceHolder.setPosition(walkPos.x,walkPos.y,walkPos.z);
                        this.m_wanderPlaceHolder.conditionallyReattach();
                     }
                     m_lastWanderTime = GlobalEngine.currentTime;
                     reloadImage();
                  }
               }
            }
         }
      }
      
      public function abortWander() : void
      {
         if(m_isWandering && m_wanderingObject == this)
         {
            stopWalking();
            setPosition(this.m_wanderStartPos.x,this.m_wanderStartPos.y,this.m_wanderStartPos.z);
            setState(this.m_wanderStartState);
            m_wanderingObject = null;
            m_isWandering = false;
            this.m_wanderPlaceHolder.detach();
            this.m_wanderPlaceHolder = null;
            this.m_wanderEndPos = null;
            conditionallyReattach();
            reloadImage();
         }
      }
      
      override public function onObjectDrop() : void
      {
         super.onObjectDrop();
         m_globalAllowWander = true;
         this.generateWanderTime();
      }
      
      override public function onSell() : void
      {
         super.onSell();
         this.m_allowWander = false;
         FeatureBuildingGiftContentDataManager.sellWorldItem(this);
      }
      
      private function petAnimal() : void
      {
         Global.selectedAvatar.getStateMachine().addState(new AMPet(Global.selectedAvatar,this),true);
         FarmStatsManager.featureSample("farm_world_action","pet_animal",this.getItem().name);
      }
      
      public function transform() : void
      {
         var currentName:String = null;
         var itemName:String = null;
         var item:FarmItem = null;
         if(!isToolGenerated)
         {
            currentName = this.getItem().name;
            itemName = this.getTransformAnimalName();
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            this.setItem(item);
            if(m_itemName != this.getItem().name)
            {
               m_itemName = this.getItem().name;
            }
            setState(STATE_BARE);
            plantTime = Global.worldTime;
            addTransaction(new TAnimalTransform(this));
         }
      }
      
      protected function getTransformAnimalName() : String
      {
         return this.getItem().transform;
      }
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         super.replaceContent(newContent,shouldRedrawMask);
      }
      
      public function set animalState(state:String) : void
      {
         this.m_animalState = state;
      }
      
      override public function isHarvestableByNeighbors() : Boolean
      {
         var result:Boolean = true;
         if(this.hasTransformAction())
         {
            result = false;
         }
         return result;
      }
      
      override public function harvest(energySource:int = 0, energy:Number = 0, showNoEnergyMessage:Boolean = true, updateBackend:Boolean = true, neighborId:String = "0") : Boolean
      {
         if(isToolGenerated)
         {
            return false;
         }
         CollectionsManager.getInstance().executeCollectionAction(CollectionsConstants.ACTION_HARVEST_ANIMAL,this as HarvestableResource,this.getPosition());
         var building:FarmItem = FeatureBuildingSurfacingManager.getInstance().conditionallyGetBuildingToSurface(this,FeatureBuildingSurfacingManager.ANIMAL_SURFACING_KEYWORD);
         if(building)
         {
            UI.displayPopup(new BuildingSurfaceWindow(building,this,true));
         }
         return super.harvest(energySource,energy,showNoEnergyMessage,updateBackend,neighborId);
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         var surfacedBuildingWindow:Boolean = false;
         var contextualBuildings:Array = null;
         var contextualBuildingsVar:String = null;
         var contextualListLenght:int = 0;
         var animalItem:AnimalItem = null;
         var index:int = 0;
         var building:BuildingItem = null;
         var babyStorageItems:Array = null;
         super.onHarvestComplete(result);
         if(BuildingSurfaceWindow.isOnContextualPlacementPromptExperiement())
         {
            contextualBuildingsVar = Global.flashHotParams["BABYANIMAL_CONTEXTUAL_BUILDINGS"] as String;
            try
            {
               contextualBuildings = com.adobe.serialization.json.JSON.decode(contextualBuildingsVar) as Array;
            }
            catch(error:Error)
            {
               contextualBuildings = [];
            }
            contextualListLenght = int(contextualBuildings.length);
            animalItem = this.getItem() as AnimalItem;
            for(index = 0; index < contextualListLenght; index++)
            {
               building = Global.farmGameSettingsManager.getFarmItemByName(contextualBuildings[index]) as BuildingItem;
               if(building != null)
               {
                  babyStorageItems = Global.storageSettings.getStorageItems(building.storageClass,true);
                  if(babyStorageItems.indexOf(animalItem) != -1)
                  {
                     if(BuildingSurfaceWindow.checkShouldDisplayPlacementPrompt(building))
                     {
                        surfacedBuildingWindow = true;
                        UI.displayPopup(new BuildingSurfaceWindow(building,null,false,null,null,null,false,true));
                        break;
                     }
                  }
               }
            }
         }
         if(!surfacedBuildingWindow)
         {
            ItemMembershipManager.conditionallyOnboardFromItem(getItem());
         }
      }
      
      override public function onFinishPlace(result:Object = null) : void
      {
         super.onFinishPlace(result);
         ItemMembershipManager.conditionallyOnboardFromItem(getItem());
      }
   }
}

