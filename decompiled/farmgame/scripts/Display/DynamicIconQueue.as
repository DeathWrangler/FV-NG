package Display
{
   import Classes.Constants.Experiments;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.MovieClipUtils;
   import Display.QueuedIcons.BeatExpansionQueuedIcon;
   import Display.QueuedIcons.CarnivalBoothQueuedIcon;
   import Display.QueuedIcons.DailyDripIcon;
   import Display.QueuedIcons.FaceOffQueuedIcon;
   import Display.QueuedIcons.FeatureCraftingQueuedIcon;
   import Display.QueuedIcons.FeatureQueuedIcon;
   import Display.QueuedIcons.FlashGiftQueuedIcon;
   import Display.QueuedIcons.LEDynamicQueuedIcon;
   import Display.QueuedIcons.LeaderboardQueuedDynamicIcon;
   import Display.QueuedIcons.LeaderboardQueuedIcon;
   import Display.QueuedIcons.MultiTaskLeaderboardQueuedIcon;
   import Display.QueuedIcons.MultipleToolTipIcon;
   import Display.QueuedIcons.QuestManagerQueuedIcon;
   import Display.QueuedIcons.QuestQueuedIcon;
   import Display.QueuedIcons.QueuedIconWithArrow;
   import Display.QueuedIcons.SpecialQuestIcon;
   import Display.QueuedIcons.SpendometerQueuedIcon;
   import Display.QueuedIcons.TaskListQueuedIcon;
   import Display.QueuedIcons.TimedGiveawayIcon;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import HolidayCountdown.HolidayCountdownMessageIcon;
   import Managers.FarmStatsManager;
   import Managers.PerformanceExperimentManager;
   import Transactions.TSaveIcons;
   import flash.display.BlendMode;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class DynamicIconQueue extends FarmGameSprite
   {
      
      public static const ADD_BY_PRIORITY:int = -1;
      
      public static const SLIDE_DIRECTION_TOP_DOWN:int = 0;
      
      public static const SLIDE_DIRECTION_BOTTOM_UP:int = 1;
      
      public static const LEFT_SIDE:int = 0;
      
      public static const RIGHT_SIDE:int = 1;
      
      protected static const TIME_BETWEEN_FLASHES:Number = 15000;
      
      protected static const FEATURE_FLASHPARAM_HUD_ICON_BLACKLIST:String = "FEATURE_FLASHPARAM_HUD_ICON_BLACKLIST";
      
      protected var m_visibleIcons:Vector.<QueuedIcon>;
      
      protected var m_numVisibleIcons:int = 0;
      
      protected var m_clickedIcon:QueuedIcon;
      
      protected var m_nextFlashTime:Number;
      
      protected var m_shine:DisplayObject;
      
      protected var m_shineLoader:Loader;
      
      protected var m_star:DisplayObject;
      
      protected var m_starLoader:Loader;
      
      protected var m_shineSprite:Sprite;
      
      protected var m_shineEffect:Sprite;
      
      protected var m_lastShined:int = 0;
      
      protected var m_iconClicks:int = 0;
      
      protected var m_slideDirection:int = 1;
      
      protected var m_side:int;
      
      public function DynamicIconQueue(iconCodes:Array = null, side:int = 0)
      {
         super();
         this.m_visibleIcons = new Vector.<QueuedIcon>();
         this.m_side = side;
         if(iconCodes != null)
         {
            this.setIcons(iconCodes);
         }
         this.scaleX = this.scaleY = 1;
         this.visible = true;
         trackClicks(false);
      }
      
      public static function checkIconBlacklist(name:String) : Boolean
      {
         var blacklistStr:String = GlobalEngine.getFlashVar(FEATURE_FLASHPARAM_HUD_ICON_BLACKLIST) as String;
         var blacklist:Array = new Array();
         if(Boolean(blacklistStr) && blacklistStr != "")
         {
            blacklist = blacklistStr.split(",");
         }
         return blacklist.indexOf(name) == -1;
      }
      
      private static function createIcon(iconName:String, extraData:Object = null, side:int = 1) : QueuedIcon
      {
         var iconTypeXmlList:XMLList = null;
         var iconType:String = null;
         var xml:XML = Global.farmGameSettingsManager.getIconXMLByName(iconName);
         var icon:QueuedIcon = null;
         if(xml != null)
         {
            iconTypeXmlList = xml.child("iconType");
            if(iconTypeXmlList.length() > 0)
            {
               iconType = iconTypeXmlList[0].toString();
               switch(iconType)
               {
                  case QueuedIcon.ICON_TYPE_FLASH_GIFT:
                     icon = new FlashGiftQueuedIcon(xml);
                     break;
                  case QueuedIcon.ICON_TYPE_FEATURE_CRAFTING:
                     icon = new FeatureCraftingQueuedIcon(xml);
                     break;
                  case QueuedIcon.ICON_TYPE_LEADERBOARD:
                     icon = new LeaderboardQueuedIcon(xml);
                     break;
                  case QueuedIcon.ICON_TYPE_LEADERBOARD_DYNAMIC:
                     icon = new LeaderboardQueuedDynamicIcon(xml);
                     break;
                  case QueuedIcon.ICON_TYPE_MULTI_TASK_LEADERBOARD:
                     icon = new MultiTaskLeaderboardQueuedIcon(xml);
                     break;
                  case QueuedIcon.ICON_TYPE_FACEOFF:
                     icon = new FaceOffQueuedIcon(xml);
                     break;
                  case QueuedIcon.ICON_TYPE_QUEST:
                     icon = new QuestQueuedIcon(xml);
                     break;
                  case QueuedIcon.ICON_TYPE_HOLIDAY_COUNTDOWN_MESSAGE_ICON:
                     icon = new HolidayCountdownMessageIcon(xml);
                     break;
                  case QueuedIcon.ICON_TYPE_FEATURE_OF_THE_WEEK:
                     icon = new FeatureQueuedIcon(xml);
                     break;
                  case CarnivalBoothQueuedIcon.CANIVAL_BOOTH_ICON_TYPE:
                     icon = new CarnivalBoothQueuedIcon(xml);
                     break;
                  case LEDynamicQueuedIcon.LE_DYNAMIC_ICON_TYPE:
                     icon = new LEDynamicQueuedIcon(xml);
                     break;
                  case TaskListQueuedIcon.TASK_LIST_ICON_TYPE:
                     icon = new TaskListQueuedIcon(xml);
                     break;
                  case SpendometerQueuedIcon.SPENDOMETER_ICON_TYPE:
                     icon = new SpendometerQueuedIcon(xml);
                     break;
                  case QuestManagerQueuedIcon.QUEST_MANAGER_ICON_TYPE:
                     icon = new QuestManagerQueuedIcon(xml);
                     break;
                  case QueuedIcon.ICON_TYPE_BEAT_EXPANSION:
                     icon = new BeatExpansionQueuedIcon(xml);
                     break;
                  case QueuedIcon.ICON_TYPE_TIMED_GIVEAWAY:
                     icon = new TimedGiveawayIcon(xml);
                     break;
                  case QueuedIcon.ICON_TYPE_DAILY_DRIP:
                     icon = new DailyDripIcon(xml);
                     break;
                  case QueuedIcon.ICON_TYPE_QUEUED_ICON_WITH_ARROW:
                     icon = new QueuedIconWithArrow(xml);
                     break;
                  case SpecialQuestIcon.SPECIAL_QUEST_ICON:
                     icon = new SpecialQuestIcon(xml);
                     break;
                  case QueuedIcon.ICON_TYPE_MULTIPLE_TOOLTIP:
                     icon = new MultipleToolTipIcon(xml);
                     break;
                  default:
                     icon = new QueuedIcon(xml);
               }
            }
            else
            {
               icon = new QueuedIcon(xml);
            }
            icon.setExtraData(extraData);
            icon.side = side;
            icon.init();
         }
         return icon;
      }
      
      public function update() : void
      {
         if(PerformanceExperimentManager.isInExtremePerformanceLimiterExperiment)
         {
            if(this.m_shineEffect)
            {
               MovieClipUtils.recursiveStop(this.m_shineEffect);
            }
            return;
         }
         if(this.m_shineEffect == null)
         {
            this.m_shineEffect = new Sprite();
            this.m_shineLoader = LoadingManager.load(Global.getAssetURL("assets/hud/hud_icon_queue/shine.swf"),this.onShineLoad);
            this.m_starLoader = LoadingManager.load(Global.getAssetURL("assets/hud/hud_icon_queue/star.swf"),this.onStarLoad);
            Utilities.toggleInputAndChildren(this.m_shineEffect,false);
            this.m_shineEffect.scaleX = this.m_shineEffect.scaleY = 1;
            this.m_shineSprite = new Sprite();
            this.m_shineSprite.blendMode = BlendMode.LAYER;
            this.m_nextFlashTime = GlobalEngine.serverTime + TIME_BETWEEN_FLASHES;
         }
         var currentTime:Number = GlobalEngine.serverTime;
         if(Boolean(this.m_shineEffect) && currentTime > this.m_nextFlashTime)
         {
            this.m_nextFlashTime = currentTime + TIME_BETWEEN_FLASHES;
            this.shine(this.m_lastShined);
            this.m_lastShined = (this.m_lastShined + 1) % this.m_numVisibleIcons;
         }
      }
      
      public function clearIcons() : void
      {
         var icon:QueuedIcon = null;
         for each(icon in this.m_visibleIcons)
         {
            if(icon.parent)
            {
               icon.removeEventListener(MouseEvent.CLICK,this.onButtonClick);
               icon.parent.removeChild(icon);
            }
         }
         this.m_visibleIcons = new Vector.<QueuedIcon>();
      }
      
      public function setVisible(visible:Boolean) : void
      {
         this.visible = visible;
      }
      
      public function set visibleIcons(numIcons:int) : void
      {
         this.m_numVisibleIcons = numIcons;
      }
      
      public function set slideDirection(direction:int) : void
      {
         this.m_slideDirection = direction;
      }
      
      public function addIcon(name:String, insertionIndex:int = -1, imageUrl:String = null, extraData:Object = null, save:Boolean = true) : QueuedIcon
      {
         var qInd:int = 0;
         var icon:QueuedIcon = DynamicIconQueue.createIcon(name,extraData,this.m_side);
         if(Boolean(icon && Global.runtimeEnabled(icon.runtimeSwitch) && icon.isWithinStartAndEndDates) && Boolean(icon.minLevel <= Global.player.level) && DynamicIconQueue.checkIconBlacklist(name))
         {
            if(imageUrl != null && imageUrl.length > 0)
            {
               icon.imageUrl = imageUrl;
            }
            this.clearGroupAndDuplicates(icon);
            if(insertionIndex >= this.m_visibleIcons.length)
            {
               insertionIndex = int(this.m_visibleIcons.length);
            }
            qInd = insertionIndex == ADD_BY_PRIORITY ? this.getIndex(icon) : insertionIndex;
            this.handleIcon(qInd,icon);
            if(icon.persists && save)
            {
               this.saveIcons();
            }
         }
         return icon;
      }
      
      public function getVisibleIconsCount() : uint
      {
         return this.m_visibleIcons.length;
      }
      
      public function refreshIconVisibility() : void
      {
         var icon:QueuedIcon = null;
         var iconPrereqs:Array = null;
         for each(icon in this.m_visibleIcons)
         {
            iconPrereqs = icon.visibilityPrereqs;
            if(iconPrereqs != null && iconPrereqs.length > 0)
            {
               if(!PrerequisiteUtility.arePrerequisitesMet(iconPrereqs))
               {
                  this.removeIconAndSurfaceNewIcon(icon);
               }
            }
         }
      }
      
      public function addIconToTop(name:String, imageUrl:String = null, extraData:Object = null, save:Boolean = true) : QueuedIcon
      {
         var result:QueuedIcon = null;
         if(Global.worldManager.isVisiting() == true)
         {
            result = this.addIcon(name,0,imageUrl,extraData,save);
         }
         else
         {
            result = this.addIcon(name,ADD_BY_PRIORITY,imageUrl,extraData,save);
         }
         return result;
      }
      
      public function addMOTDIcons(PlayerMOTD:int, newMOTD:int) : Boolean
      {
         var icon:QueuedIcon = null;
         var qInd:int = 0;
         var icons:Array = Global.farmGameSettingsManager.getIconsByMOTD(PlayerMOTD,newMOTD);
         var result:Boolean = false;
         var save:Boolean = false;
         for(var index:int = 0; index < icons.length; index++)
         {
            icon = icons[index];
            if(icon.isWithinStartAndEndDates && icon.minLevel <= Global.player.level)
            {
               this.clearGroupAndDuplicates(icon);
               qInd = this.getIndex(icon);
               this.handleIcon(qInd,icon);
               if(icon.persists)
               {
                  save = true;
               }
               result = true;
            }
         }
         if(save)
         {
            this.saveIcons();
         }
         return result;
      }
      
      protected function handleIcon(index:int, icon:QueuedIcon) : void
      {
         if(index < this.m_numVisibleIcons)
         {
            this.prepForVisibleIconAdd(index);
            this.m_visibleIcons.splice(index,0,icon);
            this.addVisibleIcon(index,icon);
         }
         else
         {
            this.m_visibleIcons.splice(index,0,icon);
         }
      }
      
      protected function addVisibleIcon(index:int, icon:QueuedIcon) : void
      {
         var shouldTween:Boolean = true;
         if(!icon.isLoaded)
         {
            icon.load();
            shouldTween = false;
         }
         this.addChild(icon);
         icon.addEventListener(MouseEvent.CLICK,this.onButtonClick);
         this.placeIcon(icon,index);
         icon.scaleX = icon.scaleY = 0;
         if(shouldTween)
         {
            icon.tweenIn();
         }
      }
      
      protected function placeIcon(icon:QueuedIcon, index:int) : void
      {
         icon.y = this.calculateIconYPosition(index);
      }
      
      protected function calculateIconYPosition(index:int) : Number
      {
         var result:Number = NaN;
         switch(this.m_slideDirection)
         {
            case SLIDE_DIRECTION_BOTTOM_UP:
               result = (QueuedIcon.BUTTON_PADDING + QueuedIcon.BUTTON_SIZE) * index;
               break;
            case SLIDE_DIRECTION_TOP_DOWN:
            default:
               result = (QueuedIcon.BUTTON_PADDING + QueuedIcon.BUTTON_SIZE) * (this.m_numVisibleIcons - index - 1);
         }
         return result;
      }
      
      public function setIcons(iconsData:Array, filterPersistantOnly:Boolean = false) : void
      {
         var iconData:Object = null;
         var icon:QueuedIcon = null;
         var checkPersistant:Boolean = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CATEGORIZED_HUD_ICON_IMPROVEMENTS) == Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
         {
            this.clearIcons();
         }
         else
         {
            this.m_visibleIcons = new Vector.<QueuedIcon>();
         }
         if(iconsData != null)
         {
            for each(iconData in iconsData)
            {
               icon = null;
               if(iconData.hasOwnProperty("iconCode"))
               {
                  if(iconData.hasOwnProperty("iconSide"))
                  {
                     if(iconData.iconSide == this.m_side)
                     {
                        icon = Global.farmGameSettingsManager.getIconByCodeOrName(iconData.iconCode);
                     }
                  }
                  else
                  {
                     icon = Global.farmGameSettingsManager.getIconByCodeOrName(iconData.iconCode);
                  }
                  if(iconData.hasOwnProperty("imageUrl") && Boolean(icon))
                  {
                     icon.imageUrl = iconData.imageUrl;
                  }
                  if(iconData.hasOwnProperty("iconExtraData") && Boolean(icon))
                  {
                     icon.extraData = iconData.iconExtraData;
                  }
               }
               else if(iconData is String)
               {
                  icon = Global.farmGameSettingsManager.getIconByCodeOrName(iconData as String);
               }
               if(icon)
               {
                  checkPersistant = true;
                  if(filterPersistantOnly)
                  {
                     checkPersistant = icon.persists;
                  }
                  if(Boolean(Global.runtimeEnabled(icon.runtimeSwitch) && icon && checkPersistant) && Boolean(icon.isWithinStartAndEndDates) && icon.minLevel <= Global.player.level)
                  {
                     this.addIcon(icon.iconName,ADD_BY_PRIORITY,icon.imageUrl,icon.extraData);
                  }
               }
            }
         }
      }
      
      protected function getIndex(icon:QueuedIcon) : int
      {
         var result:int = 0;
         for(result = 0; result < this.m_visibleIcons.length; result++)
         {
            if(this.m_visibleIcons[result].priority >= icon.priority)
            {
               break;
            }
         }
         return result;
      }
      
      protected function clearGroupAndDuplicates(icon:QueuedIcon) : void
      {
         var visibleIcon:QueuedIcon = null;
         var removeGroup:Boolean = false;
         var removeIdentical:Boolean = false;
         for each(visibleIcon in this.m_visibleIcons)
         {
            removeGroup = icon.group != "" && icon.group == visibleIcon.group;
            removeIdentical = visibleIcon.code != "" && icon.code == visibleIcon.code;
            if(removeGroup || removeIdentical)
            {
               this.removeIconAndSurfaceNewIcon(visibleIcon);
            }
         }
      }
      
      public function removeIconByName(name:String) : void
      {
         var visibleIcon:QueuedIcon = null;
         for each(visibleIcon in this.m_visibleIcons)
         {
            if(visibleIcon.iconName == name)
            {
               this.removeIconAndSurfaceNewIcon(visibleIcon);
               break;
            }
         }
      }
      
      public function removeIconByCode(code:String) : void
      {
         var visibleIcon:QueuedIcon = null;
         for each(visibleIcon in this.m_visibleIcons)
         {
            if(visibleIcon.code == code)
            {
               this.removeIconAndSurfaceNewIcon(visibleIcon);
               break;
            }
         }
      }
      
      public function removeIcon(icon:QueuedIcon) : void
      {
         this.removeIconAndSurfaceNewIcon(icon);
      }
      
      protected function removeIconAndSurfaceNewIcon(icon:QueuedIcon) : void
      {
         var removedIndex:int = this.removeVisibleIcon(icon);
         if(removedIndex >= 0)
         {
            this.m_visibleIcons.splice(removedIndex,1);
            if(icon.persists)
            {
               this.saveIcons();
            }
         }
      }
      
      protected function removeVisibleIconAtIndex(indexToRemove:int) : Boolean
      {
         var isSuccessfulRemove:Boolean = false;
         if(indexToRemove >= 0 && indexToRemove < this.m_visibleIcons.length)
         {
            this.m_visibleIcons.splice(indexToRemove,1);
         }
         return isSuccessfulRemove;
      }
      
      protected function removeVisibleIcon(icon:QueuedIcon, isReplacing:Boolean = false) : int
      {
         var maxIndex:int = 0;
         var newlyVisibleIcon:QueuedIcon = null;
         var removedIndex:int = this.m_visibleIcons.indexOf(icon);
         if(removedIndex >= 0 && removedIndex < this.m_numVisibleIcons)
         {
            icon.removeEventListener(MouseEvent.CLICK,this.onButtonClick);
            icon.tweenOut();
            maxIndex = Math.min(this.m_visibleIcons.length,this.m_numVisibleIcons);
            if(isReplacing == true)
            {
               this.shiftIconsAtIndex(removedIndex,false);
               if(this.m_numVisibleIcons < this.m_visibleIcons.length)
               {
                  newlyVisibleIcon = this.m_visibleIcons[maxIndex];
                  this.addVisibleIcon(maxIndex - 1,newlyVisibleIcon);
               }
            }
         }
         return removedIndex;
      }
      
      protected function prepForVisibleIconAdd(newIconIndex:int) : void
      {
         var maxIndex:int = 0;
         var icon:QueuedIcon = null;
         if(newIconIndex < this.m_visibleIcons.length)
         {
            maxIndex = Math.min(this.m_visibleIcons.length,this.m_numVisibleIcons);
            this.shiftIconsAtIndex(newIconIndex,true);
            icon = null;
            icon = this.m_visibleIcons[maxIndex - 1];
            if(maxIndex < this.m_numVisibleIcons)
            {
               this.handleAddIconTween(maxIndex - 1,icon);
            }
            else
            {
               icon.removeEventListener(MouseEvent.CLICK,this.onButtonClick);
               icon.tweenOut();
            }
         }
      }
      
      protected function shiftIconsAtIndex(piviotIndex:int, isAddingIcon:Boolean) : void
      {
         var icon:QueuedIcon = null;
         var shiftMethod:Function = null;
         var currentIconCount:int = Math.min(this.m_visibleIcons.length,this.m_numVisibleIcons + 1);
         var maxIndex:int = 0;
         if(isAddingIcon == true)
         {
            shiftMethod = this.handleAddIconTween;
            maxIndex = currentIconCount;
         }
         else
         {
            shiftMethod = this.handleRemoveIconTween;
            maxIndex = currentIconCount;
         }
         for(var index:int = piviotIndex; index < maxIndex; index++)
         {
            icon = this.m_visibleIcons[index];
            shiftMethod(index,icon);
         }
      }
      
      protected function handleRemoveIconTween(iconIndex:int, icon:QueuedIcon) : void
      {
         switch(this.m_slideDirection)
         {
            case SLIDE_DIRECTION_BOTTOM_UP:
               icon.tweenDirection(iconIndex,QueuedIcon.TWEEN_UP);
               break;
            case SLIDE_DIRECTION_TOP_DOWN:
            default:
               icon.tweenDirection(this.m_numVisibleIcons - iconIndex - 1,QueuedIcon.TWEEN_DOWN);
         }
      }
      
      protected function handleAddIconTween(index:int, icon:QueuedIcon) : void
      {
         switch(this.m_slideDirection)
         {
            case SLIDE_DIRECTION_BOTTOM_UP:
               icon.tweenDirection(index,QueuedIcon.TWEEN_DOWN);
               break;
            case SLIDE_DIRECTION_TOP_DOWN:
            default:
               icon.tweenDirection(this.m_numVisibleIcons - index - 1,QueuedIcon.TWEEN_UP);
         }
      }
      
      protected function onShineLoad(event:Event) : void
      {
         this.m_shine = this.m_shineLoader.content;
         this.m_shine.x -= QueuedIcon.BUTTON_SIZE / 2;
         this.m_shine.y -= QueuedIcon.BUTTON_SIZE / 2;
         this.m_shineSprite.addChild(this.m_shine);
         this.m_shineEffect.addChild(this.m_shineSprite);
      }
      
      protected function onStarLoad(event:Event) : void
      {
         this.m_star = this.m_starLoader.content;
         this.m_star.x -= 30;
         this.m_star.y -= 5;
         this.m_shineEffect.addChild(this.m_star);
      }
      
      protected function shine(whichIcon:int) : void
      {
         var icon:QueuedIcon = null;
         if(this.m_shineEffect)
         {
            if(PerformanceExperimentManager.isInExtremePerformanceLimiterExperiment)
            {
               if(this.m_shineEffect.parent)
               {
                  MovieClipUtils.recursiveStop(this.m_shineEffect);
               }
            }
            else if(this.m_shineEffect.numChildren >= 2)
            {
               if(!this.m_shineEffect.parent)
               {
                  this.addChild(this.m_shineEffect);
               }
               icon = null;
               if(whichIcon < this.m_visibleIcons.length)
               {
                  icon = this.m_visibleIcons[whichIcon];
               }
               else if(this.m_visibleIcons.length > 0)
               {
                  icon = this.m_visibleIcons[0];
               }
               if(this.getChildIndex(this.m_shineEffect) != this.numChildren - 1)
               {
                  this.setChildIndex(this.m_shineEffect,this.numChildren - 1);
               }
               if(Boolean(icon) && Boolean(icon.alphaMask))
               {
                  if(this.m_shineSprite.numChildren > 1)
                  {
                     this.m_shineSprite.removeChildAt(1);
                  }
                  this.m_shineSprite.addChild(icon.alphaMask);
                  this.m_shineEffect.y = icon.y;
                  if(this.m_shine is MovieClip && this.m_star is MovieClip)
                  {
                     (this.m_shine as MovieClip).play();
                     (this.m_star as MovieClip).play();
                  }
               }
            }
         }
      }
      
      protected function onButtonClick(event:Event) : void
      {
         Utilities.toggleInputOnlySelf(this,false);
         var icon:QueuedIcon = null;
         if(event.currentTarget is QueuedIcon)
         {
            icon = event.currentTarget as QueuedIcon;
         }
         if(icon)
         {
            this.m_clickedIcon = icon;
            this.doButtonStats(icon);
            if(!icon.removeOnClick)
            {
               icon.finishClick(this);
               if(icon.hasPopup)
               {
                  icon.displayPopup(this.onPopupClick);
               }
            }
            else
            {
               this.removeIconAndSurfaceNewIcon(icon);
               if(icon.hasPopup)
               {
                  icon.displayPopup(this.onPopupClick);
               }
               else
               {
                  this.finishClickHandling();
               }
            }
         }
      }
      
      protected function doButtonStats(icon:QueuedIcon) : void
      {
         FarmStatsManager.count("hud_icon2",icon.iconName,this.m_iconClicks.toString());
         ++this.m_iconClicks;
         if(this.m_visibleIcons.length == 2)
         {
            FarmStatsManager.count("hud_icon2","finished");
         }
         icon.doClickStats();
      }
      
      protected function finishClickHandling() : void
      {
         Utilities.toggleInputOnlySelf(this,true);
         this.m_clickedIcon.finishClick(this);
         this.m_clickedIcon.dispose();
         this.m_clickedIcon = null;
      }
      
      protected function onPopupClick(event:Event) : void
      {
         if((event as GenericPopupEvent).button == 1)
         {
            this.finishClickHandling();
         }
         Utilities.toggleInputOnlySelf(this,true);
      }
      
      public function saveIcons() : void
      {
         var queuedIcon:QueuedIcon = null;
         var iconCode:String = null;
         var iconExtraData:Object = null;
         var numericSenders:Array = null;
         var stringSenders:Array = null;
         var uid:String = null;
         var saveArray:Array = [];
         for each(queuedIcon in this.m_visibleIcons)
         {
            if(queuedIcon.persists)
            {
               iconCode = queuedIcon.code != "" ? queuedIcon.code : queuedIcon.name;
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CONVERT_ICON_SENDER_ID_TO_STRING))
               {
                  iconExtraData = queuedIcon.extraData;
                  if(iconExtraData)
                  {
                     numericSenders = iconExtraData.senders as Array;
                     if(numericSenders)
                     {
                        stringSenders = [];
                        for each(uid in numericSenders)
                        {
                           stringSenders.push(uid);
                        }
                        queuedIcon.extraData.senders = stringSenders;
                     }
                  }
               }
               saveArray.push({
                  "iconCode":iconCode,
                  "iconSide":this.m_side,
                  "iconExtraData":queuedIcon.extraData,
                  "imageUrl":queuedIcon.imageUrl
               });
            }
         }
         TransactionManager.addTransaction(new TSaveIcons(saveArray));
      }
      
      public function getIconByName(name:String) : QueuedIcon
      {
         var result:QueuedIcon = null;
         for(var qInd:int = 0; qInd < this.m_visibleIcons.length; qInd++)
         {
            if(this.m_visibleIcons[qInd].iconName == name)
            {
               result = this.m_visibleIcons[qInd];
               break;
            }
         }
         return result;
      }
      
      public function getIconByImage(imageUrl:String) : QueuedIcon
      {
         var result:QueuedIcon = null;
         for(var qInd:int = 0; qInd < this.m_visibleIcons.length; qInd++)
         {
            if(this.m_visibleIcons[qInd].imageUrl == imageUrl)
            {
               result = this.m_visibleIcons[qInd];
               break;
            }
         }
         return result;
      }
      
      public function getIconByFeatureName(featureName:String) : QueuedIcon
      {
         var result:QueuedIcon = null;
         for(var qInd:int = 0; qInd < this.m_visibleIcons.length; qInd++)
         {
            if(this.m_visibleIcons[qInd] is FeatureQueuedIcon && (this.m_visibleIcons[qInd] as FeatureQueuedIcon).getFeatureName() == featureName)
            {
               result = this.m_visibleIcons[qInd];
               break;
            }
         }
         return result;
      }
   }
}

