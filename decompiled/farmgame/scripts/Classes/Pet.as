package Classes
{
   import AvatarMode.AMPet;
   import Classes.Idle.AdultPetTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.PetFarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.GenericPopupTitleBig;
   import Display.PetsLearnTricksPopup;
   import Display.UI;
   import Engine.Constants;
   import Engine.Helpers.Vector3;
   import Engine.Managers.SoundManager;
   import Engine.Utilities;
   import Events.GenericPopupTitleBigEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.PetManager;
   import Managers.ToasterManager;
   import Transactions.TMove;
   import Transactions.TPetAdulthoodReached;
   import Transactions.TPetItemRequestEvent;
   import Transactions.TPetRunaway;
   import Transactions.TRescuePet;
   import Transactions.TUseTargetedConsumable;
   import Widgets.Windows.GenericCustomAdToaster;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class Pet extends Animal
   {
      
      protected static var m_thoughtBubbleBitmapData:BitmapData;
      
      public static const MENU_ALLOW_FOLLOW:String = "allowFollow";
      
      public static const MENU_DISALLOW_FOLLOW:String = "disallowFollow";
      
      public static const MENU_FEED_PET:String = "feedPet";
      
      public static const MENU_ASK_FOR_FOOD:String = "askForFood";
      
      public static const MENU_NEXT_LEVEL_TRICK:String = "nextTrick";
      
      public static const STATE_SIT:String = "sit";
      
      public static const STATE_TICKLE:String = "tickle";
      
      public static const STATE_ROLLOVER:String = "rollover";
      
      public static const STATE_PLAYDEAD:String = "playdead";
      
      public static const STATE_SHAKE:String = "shake";
      
      public static const STATE_FOLLOW:String = "run";
      
      public static const STATE_RUNAWAY:String = "runaway";
      
      public static const STATE_HARVEST:String = "harvest";
      
      public static const STATE_FETCH:String = "fetch";
      
      public static const STATE_HERD:String = "herd";
      
      public static const LEVEL_RESET_MESSAGE_DELAY:Number = 30000;
      
      public static const HUNGRY_REMINDER_DELAY:Number = 60000;
      
      public static const RESCUE_REMINDER_DELAY:Number = 30000;
      
      public static const REMINDER_POPUP_DURATION:Number = 20;
      
      public static const ADULT_START_UNLOCK_LEVEL:Number = 2;
      
      public static const FEED_ITEM_NON_ADULT:String = "consume_kibble";
      
      public static const FEED_ITEM_ADULT:String = "consume_treat";
      
      public static const ITEM_PET_RESCUE:String = "pet_rescue";
      
      public static const PET_TRICK_HARVEST:String = "harvest";
      
      public static const PET_TRICK_FETCH:String = "fetch";
      
      public static const PET_ASK_FRIENDS_FREQ_KEY:String = "askFriendsFreqKey";
      
      public static const THOUGHT_BUBBLE_DELAY:int = 2000;
      
      public static const PET_AVATAR_MIN_DISTANCE:Number = 2.5;
      
      public static const PET_AVATAR_MIN_DISTANCE_MOVING:Number = 5.1;
      
      public static const PET_FOLLOW_PERIOD:Number = 0.125;
      
      public static const PET_NO_FOLLOW_PENALTY_PERIOD:Number = 10;
      
      public static const PET_DAYS_TO_GROW:int = 14;
      
      public static const PET_HOURS_TO_BE_HUNGRY:int = 6;
      
      public static const GENDER_FEMALE:Number = 0;
      
      public static const GENDER_MALE:Number = 1;
      
      public static const FORGOT_TRICKS_ICON:String = "assets/hud/FV_forgot_trick_icon_100x100.png";
      
      protected static var m_timeToFollowStatic:Number = 0;
      
      protected var m_petName:String = "";
      
      protected var m_petGender:Number = 0;
      
      protected var m_petState:String = "";
      
      protected var m_petLevel:int = 0;
      
      protected var m_lastFedTime:Number = 0;
      
      protected var m_levelStartTime:Number = 0;
      
      protected var m_kibbleFedCount:int = 0;
      
      protected var m_daysSincePurchase:int = 0;
      
      protected var m_timeUntilHungryAgain:Number = 0;
      
      protected var m_timeToFollow:Number = 0;
      
      protected var m_isFollowing:Boolean = false;
      
      protected var m_isPerformingTrick:Boolean = false;
      
      protected var m_isReturningFromTrick:Boolean = false;
      
      protected var m_allowFollow:Boolean = true;
      
      protected var m_followPlaceHolder:Animal;
      
      protected var m_isHungry:Boolean = false;
      
      protected var m_isCash:Boolean = true;
      
      private var m_isRunaway:Boolean = false;
      
      private var m_isRescue:Boolean = false;
      
      private var m_levelResetMessageTime:Number = 0;
      
      private var m_petTrickTime:Number = 0;
      
      private var m_petBubbleTime:Number = 0;
      
      private var m_petReminderPopupDelayTime:Number = 0;
      
      private var m_petHungryPopupShown:Boolean = false;
      
      private var m_petRescueReminderClicked:Boolean = false;
      
      private var m_timer:Timer = null;
      
      private var m_hasUserSeenAdult:Boolean = false;
      
      private var m_wasLevelResetOnLoad:Boolean = false;
      
      private var m_onStopTrickCallback:Function = null;
      
      private var m_petItem:PetFarmItem;
      
      private var m_rescueReminderDaysLimit:Number;
      
      private var m_currentPos:Vector3;
      
      public function Pet(animalType:String = null)
      {
         super(animalType);
         this.m_petItem = PetConfig.getPetItem(m_item.name);
         this.m_rescueReminderDaysLimit = Global.farmGameSettingsManager.getNumber("petRescueReminderDaysLimit",7);
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         this.m_petName = data.petName;
         this.m_petGender = data.petGender;
         this.m_petLevel = data.petLevel;
         this.m_allowFollow = data.allowFollow;
         m_direction = data.direction;
         this.m_lastFedTime = data.lastFedTime;
         this.m_kibbleFedCount = data.kibbleFedCount;
         if(this.m_kibbleFedCount > PET_DAYS_TO_GROW)
         {
            this.m_kibbleFedCount = PET_DAYS_TO_GROW;
         }
         this.m_isCash = data.isCash;
         this.m_hasUserSeenAdult = data.hasUserSeenAdult;
         this.m_wasLevelResetOnLoad = data.wasLevelResetOnLoad;
         this.m_levelStartTime = data.levelStartTime;
         if(!this.m_isCash)
         {
            this.m_petReminderPopupDelayTime = GlobalEngine.currentTime + Pet.HUNGRY_REMINDER_DELAY;
         }
         if(this.m_wasLevelResetOnLoad)
         {
            this.m_levelResetMessageTime = GlobalEngine.currentTime + Pet.LEVEL_RESET_MESSAGE_DELAY;
         }
         this.animalState = Pet.STATE_SIT;
         if(Boolean(data && data.isRunAway) && Boolean(!this.m_isCash) && this.isHungry())
         {
            this.setRunaway();
         }
         this.updateFedState();
      }
      
      private function isPetPerformingTrick() : Boolean
      {
         var isTrick:Boolean = false;
         switch(this.m_petState)
         {
            case Pet.STATE_TICKLE:
            case Pet.STATE_ROLLOVER:
            case Pet.STATE_PLAYDEAD:
            case Pet.STATE_SHAKE:
               isTrick = true;
         }
         return isTrick;
      }
      
      override public function showMenu() : void
      {
         var askForFoodString:String = null;
         if(!Global.worldManager.isVisiting())
         {
            m_menuItems = [];
            if(!this.isPetPerformingTrick() && this.m_petState != Pet.STATE_FOLLOW)
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("FarmGame","Move"),
                  "action":MOVE_OBJECT
               });
               if(!this.isCollingWithObjects())
               {
                  if(this.m_allowFollow)
                  {
                     m_menuItems.push({
                        "label":ZLocUtils.t("FarmGame","DisallowFollow"),
                        "action":MENU_DISALLOW_FOLLOW
                     });
                  }
                  else
                  {
                     m_menuItems.push({
                        "label":ZLocUtils.t("FarmGame","AllowFollow"),
                        "action":MENU_ALLOW_FOLLOW
                     });
                  }
               }
               if(!this.isFinalTrick())
               {
                  if(this.isHungry())
                  {
                     m_menuItems.push({
                        "label":ZLocUtils.t("FarmGame","FeedPet"),
                        "action":MENU_FEED_PET
                     });
                  }
                  else if(this.getAvailableFoodCount() == 0)
                  {
                     askForFoodString = this.isAdult() ? "AskForTreats" : "AskForKibble";
                     m_menuItems.push({
                        "label":ZLocUtils.t("FarmGame",askForFoodString),
                        "action":MENU_ASK_FOR_FOOD
                     });
                  }
               }
               if(Global.player.level >= Global.farmGameSettingsManager.getInt("sellLockLevel",7))
               {
                  m_menuItems.push({
                     "label":ZLocUtils.t("FarmGame","Sell"),
                     "action":SELL_OBJECT
                  });
               }
               m_menuItems.push({
                  "label":ZLocUtils.t("FarmGame","Rotate"),
                  "action":ROTATE_OBJECT
               });
               m_menuItems.push({
                  "label":ZLocUtils.t("FarmGame","Tickle"),
                  "action":STATE_TICKLE
               });
               if(this.isAdult())
               {
                  this.showAdultContextMenu();
               }
            }
            UI.displayMenu(m_menuItems,this.onMenuClick);
         }
      }
      
      private function showAdultContextMenu() : void
      {
         var trickName:String = null;
         var trickText:String = null;
         var level:Number = NaN;
         if(this.m_petItem)
         {
            for(level = Pet.ADULT_START_UNLOCK_LEVEL; level <= this.petLevel; level++)
            {
               trickName = this.m_petItem.getLevelTrick(level);
               trickText = PetConfig.getTrickFriendlyName(trickName);
               if(level == PetConfig.getMaxLevel())
               {
                  if(this.m_petItem.getTrickHarvestType(level))
                  {
                     trickText = PetConfig.getTrickFriendlyName(trickName + "_" + this.m_petItem.getTrickHarvestType(level));
                  }
               }
               m_menuItems.push({
                  "label":trickText,
                  "action":trickName
               });
            }
            if(this.petLevel < PetConfig.getMaxLevel())
            {
               trickName = this.m_petItem.getLevelTrick(this.getNextLevel());
               trickText = PetConfig.getTrickFriendlyName(trickName);
               trickText = ZLocUtils.t("Dialogs","PetTrickLocked",{"trick":trickText});
               m_menuItems.push({
                  "label":trickText,
                  "action":MENU_NEXT_LEVEL_TRICK
               });
            }
         }
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var logMenuClick:Boolean = false;
         var item:ContextMenuItem = null;
         var petStat:String = null;
         if(event.target is ContextMenuItem)
         {
            logMenuClick = true;
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case MENU_ALLOW_FOLLOW:
                  this.setAllowFollow(true);
                  break;
               case MENU_DISALLOW_FOLLOW:
                  this.setAllowFollow(false);
                  break;
               case STATE_TICKLE:
               case STATE_ROLLOVER:
               case STATE_PLAYDEAD:
               case STATE_SHAKE:
                  this.startTrickAnimation(item.action);
                  break;
               case STATE_HARVEST:
               case STATE_FETCH:
               case STATE_HERD:
                  this.performTrick();
                  break;
               case MENU_FEED_PET:
                  if(this.getAvailableFoodCount() > 0 && this.isHungry())
                  {
                     addTransaction(new TUseTargetedConsumable(this.getPetFeedItemName(),getId()),true);
                  }
                  else
                  {
                     this.displayAskForFoodDialog();
                  }
                  break;
               case MENU_ASK_FOR_FOOD:
                  this.displayAskForFoodDialog();
                  break;
               case MENU_NEXT_LEVEL_TRICK:
                  FarmStatsManager.count("fv_pets","click_locked_trick_menu");
                  UI.displayPopup(new PetsLearnTricksPopup(this));
                  break;
               default:
                  super.onMenuClick(event);
                  logMenuClick = false;
            }
            if(logMenuClick)
            {
               petStat = this.isAdult() ? "adultpet" : "puppy";
               FarmStatsManager.count("fv_pets","menu_click",petStat,item.action);
            }
         }
      }
      
      override public function onUpdate(delta:Number) : void
      {
         var msecSinceLastFeed:Number = NaN;
         var daysSinceLastFeed:Number = NaN;
         var isTimeToNotify:Boolean = false;
         if(!isNaN(delta))
         {
            if(this.isPetPerformingTrick())
            {
               if(this.m_petTrickTime < GlobalEngine.currentTime)
               {
                  this.stopTrickAnimation();
               }
            }
            if(this.m_petState == Pet.STATE_SIT && m_hideArrow)
            {
               if(this.m_petBubbleTime < GlobalEngine.currentTime)
               {
                  this.showBubble();
               }
            }
            if(this.m_petState == Pet.STATE_RUNAWAY && !PetManager.getInstance().petRescueReminderShown)
            {
               msecSinceLastFeed = Global.worldTime - this.m_lastFedTime;
               daysSinceLastFeed = Math.floor(msecSinceLastFeed / FarmGameUtil.NUM_MSECS_IN_DAY);
               if(this.m_lastFedTime != 0 && daysSinceLastFeed > this.m_rescueReminderDaysLimit)
               {
                  PetManager.getInstance().petRescueReminderShown = true;
               }
               else if(this.m_petReminderPopupDelayTime < GlobalEngine.currentTime)
               {
                  PetManager.getInstance().petRescueReminderShown = true;
                  PetManager.getInstance().showPetRescueReminder();
               }
            }
            if(this.m_petState == Pet.STATE_SIT && !this.m_petHungryPopupShown && !this.isHungry() && (this.isAdult() || !this.m_isCash))
            {
               isTimeToNotify = this.getHoursUntilHungryAgain() <= PET_HOURS_TO_BE_HUNGRY && this.getMinutesUntilHungryAgain() > 0;
               if(isTimeToNotify && this.m_petReminderPopupDelayTime < GlobalEngine.currentTime)
               {
                  this.m_petHungryPopupShown = true;
                  this.showPetHungryReminder();
               }
            }
            if(this.isAdult() && !this.m_hasUserSeenAdult)
            {
               this.displayReachedAdultMessage();
               Global.worldManager.addPostSwapTransaction(new TPetAdulthoodReached(this));
               this.m_hasUserSeenAdult = true;
            }
            if(this.isAdult() && this.m_wasLevelResetOnLoad && this.petLevel < PetConfig.getMaxLevel())
            {
               if(this.m_levelResetMessageTime < GlobalEngine.currentTime)
               {
                  PetManager.getInstance().addLevelResetPet(this);
                  this.m_wasLevelResetOnLoad = false;
               }
            }
            if(!SoundManager.isMuted())
            {
               m_soundTime -= delta;
               if(m_soundTime <= 0)
               {
                  playRandomSound();
                  generateSoundTime();
               }
               else if(isNaN(m_soundTime))
               {
                  generateSoundTime();
               }
            }
            m_timeSinceGrowUpdate += delta;
            if(m_timeSinceGrowUpdate >= GROW_UPDATE_RATE)
            {
               m_timeSinceGrowUpdate = 0;
               this.updateFedState();
            }
            if(this.m_allowFollow && this.m_petState != Pet.STATE_RUNAWAY)
            {
               this.m_timeToFollow -= delta;
               m_timeToFollowStatic -= delta;
               if(this.m_timeToFollow <= 0 && m_timeToFollowStatic <= 0)
               {
                  this.m_timeToFollow = 0;
                  m_timeToFollowStatic = PET_FOLLOW_PERIOD;
                  this.followAvatar();
               }
            }
            this.updateToolTipText();
         }
      }
      
      private function updateFedState() : void
      {
         var msecSinceLastDay:Number = NaN;
         var todayBeganAt:Number = NaN;
         var yesterdayBeganAt:Number = NaN;
         var msecSinceLevelStart:Number = NaN;
         var msecSincePurchase:Number = NaN;
         if(plantTime > 0 && this.petLevel < PetConfig.getMaxLevel())
         {
            if(this.isAdult())
            {
               if(!Global.worldManager.isVisiting())
               {
                  msecSinceLevelStart = Global.worldTime - this.m_levelStartTime;
                  msecSinceLastDay = msecSinceLevelStart % FarmGameUtil.NUM_MSECS_IN_DAY;
                  todayBeganAt = Global.worldTime - msecSinceLastDay;
                  yesterdayBeganAt = todayBeganAt - FarmGameUtil.NUM_MSECS_IN_DAY;
                  this.m_timeUntilHungryAgain = FarmGameUtil.NUM_MSECS_IN_DAY - msecSinceLastDay;
                  if(this.m_lastFedTime < yesterdayBeganAt && this.m_wasLevelResetOnLoad)
                  {
                     this.m_kibbleFedCount = 0;
                     this.m_levelStartTime = 0;
                     this.m_wasLevelResetOnLoad = false;
                     this.displayLevelProgressReset();
                     FarmStatsManager.count("fv_pets","progress_lost","level_" + this.m_petLevel.toString(),"age_" + this.m_daysSincePurchase.toString());
                  }
                  else if(this.m_lastFedTime < todayBeganAt && this.m_kibbleFedCount < PET_DAYS_TO_GROW)
                  {
                     this.m_isHungry = true;
                     if(m_arrow == null)
                     {
                        m_arrow = this.generateThoughtBubble();
                     }
                  }
               }
               else
               {
                  this.m_isHungry = true;
               }
            }
            else
            {
               msecSincePurchase = Global.worldTime - plantTime;
               this.m_daysSincePurchase = Math.floor(msecSincePurchase / FarmGameUtil.NUM_MSECS_IN_DAY);
               if(this.m_daysSincePurchase < PET_DAYS_TO_GROW || !this.m_isCash && this.m_kibbleFedCount < PET_DAYS_TO_GROW)
               {
                  msecSinceLastDay = msecSincePurchase % FarmGameUtil.NUM_MSECS_IN_DAY;
                  todayBeganAt = Global.worldTime - msecSinceLastDay;
                  yesterdayBeganAt = todayBeganAt - FarmGameUtil.NUM_MSECS_IN_DAY;
                  this.m_timeUntilHungryAgain = FarmGameUtil.NUM_MSECS_IN_DAY - msecSinceLastDay;
                  if(!this.isRescue && !this.m_isCash && this.m_lastFedTime < yesterdayBeganAt && this.m_daysSincePurchase >= 1 && GlobalEngine.getFlashVar("disallowPetRunaway") != 1 && !Global.worldManager.isVisiting() && this.m_kibbleFedCount < PET_DAYS_TO_GROW)
                  {
                     if(!this.m_isRunaway && this.m_petState != Pet.STATE_RUNAWAY)
                     {
                        this.setRunaway();
                        Global.worldManager.addPostSwapTransaction(new TPetRunaway(this));
                        FarmStatsManager.count("fv_pets","runaway","coin_" + getId().toString(),"fed_" + this.m_kibbleFedCount.toString() + "_times","age_" + this.m_daysSincePurchase.toString());
                     }
                  }
                  else if(this.m_lastFedTime < todayBeganAt && !Global.worldManager.isVisiting() && this.m_kibbleFedCount < PET_DAYS_TO_GROW)
                  {
                     this.m_isHungry = true;
                     if(m_arrow == null)
                     {
                        m_arrow = this.generateThoughtBubble();
                     }
                  }
               }
            }
         }
      }
      
      protected function generateThoughtBubble() : DisplayObject
      {
         var bubble:DisplayObject = null;
         if(this.petLevel < PetConfig.getMaxLevel())
         {
            if(this.isAdult())
            {
               bubble = new EmbeddedArt.thoughtBubbleTreat();
            }
            else
            {
               bubble = new EmbeddedArt.thoughtBubbleKibble();
            }
            if(m_thoughtBubbleBitmapData == null)
            {
               m_thoughtBubbleBitmapData = new BitmapData(bubble.width,bubble.height,true,0);
               m_thoughtBubbleBitmapData.draw(bubble);
            }
         }
         return bubble;
      }
      
      override protected function getArrowBitmapData() : BitmapData
      {
         return m_thoughtBubbleBitmapData;
      }
      
      private function followAvatar() : void
      {
         var currentPos:Vector3 = null;
         var walkPos:Vector3 = null;
         var petToAvatarDistance:Number = NaN;
         var maxPetToAvatarDistance:Number = NaN;
         var mouseEnabled:Boolean = Global.ui.mouseEnabled;
         if(mouseEnabled && !this.m_isFollowing && m_attachPosition != null && getId() > 0)
         {
            currentPos = getPosition();
            walkPos = Global.player.avatar.getPosition();
            petToAvatarDistance = walkPos.subtract(currentPos).length();
            maxPetToAvatarDistance = Global.player.avatar.isWalking() ? PET_AVATAR_MIN_DISTANCE_MOVING : PET_AVATAR_MIN_DISTANCE;
            if(petToAvatarDistance > maxPetToAvatarDistance)
            {
               m_WalkSpeed = Global.farmGameSettingsManager.getNumber("animalFollowSpeed");
               this.m_isFollowing = walkTo(walkPos.x,walkPos.y,PET_AVATAR_MIN_DISTANCE);
               if(this.m_isFollowing)
               {
                  this.createFollowPlaceHolder(getCurrentDestination());
                  this.animalState = Pet.STATE_FOLLOW;
               }
               else
               {
                  this.m_timeToFollow = PET_NO_FOLLOW_PENALTY_PERIOD;
               }
            }
         }
      }
      
      override protected function onDoneWalking() : void
      {
         if(this.m_isFollowing || this.m_isPerformingTrick)
         {
            if(this.m_isPerformingTrick)
            {
               this.onTrickRoundTrip();
            }
            else
            {
               this.m_isFollowing = false;
               this.removeFollowPlaceHolder();
               this.animalState = Pet.STATE_SIT;
            }
         }
      }
      
      override public function move() : void
      {
         this.m_allowFollow = false;
         super.move();
      }
      
      private function startTrickAnimation(menuAction:String, onStopTrickCallback:Function = null) : void
      {
         this.m_onStopTrickCallback = onStopTrickCallback;
         Global.selectedAvatar.getStateMachine().addState(new AMPet(Global.selectedAvatar,this as Pet,menuAction),true);
      }
      
      private function performTrick() : void
      {
         var trickName:String = null;
         var failedMessage:String = null;
         var trick:PetTrick = PetTrick.createPetTrick(this);
         if(trick != null)
         {
            this.setAllowFollow(false,false);
            trickName = this.m_petItem.getLevelTrick(this.petLevel);
            if(trickName == Pet.PET_TRICK_FETCH)
            {
               if(trick.canPerformTrick(this.getId()))
               {
                  this.runAround();
                  trick.perform();
               }
               else
               {
                  failedMessage = ZLocUtils.t("Dialogs","PetTrick_fetch_failed",{"pet":ZLocUtils.tn(this.petName,this.isMale() ? ZLocUtils.MASC : ZLocUtils.FEM)});
                  UI.displayMessage(failedMessage,0,null,"",true);
               }
            }
            else if(trick.canPerformTrick(this.getId()))
            {
               this.runTowardsWorldObject();
               trick.perform();
            }
            else
            {
               PetManager.getInstance().onPetTrickHarvestAnimalTooSoon(this);
            }
         }
      }
      
      private function stopTrickAnimation() : void
      {
         this.animalState = Pet.STATE_SIT;
         if(this.m_onStopTrickCallback != null)
         {
            this.m_onStopTrickCallback();
            this.m_onStopTrickCallback = null;
         }
      }
      
      private function setAllowFollow(value:Boolean, updateServer:Boolean = true) : void
      {
         this.m_allowFollow = value;
         if(updateServer)
         {
            this.syncPosition();
         }
      }
      
      private function setRunaway() : void
      {
         this.m_allowFollow = false;
         this.m_isRunaway = true;
         this.animalState = Pet.STATE_RUNAWAY;
         setPosition(Global.world.getGridWidth(),Global.world.getGridHeight());
      }
      
      private function syncPosition(position:Vector3 = null) : void
      {
         var mapObject:MapResource = null;
         var params:Object = null;
         if(!Global.worldManager.isVisiting())
         {
            mapObject = this as MapResource;
            if(null == position)
            {
               position = m_position;
            }
            params = new Object();
            params.x = Math.round(position.x);
            params.y = Math.round(position.y);
            params.direction = m_direction;
            params.allowFollow = this.m_allowFollow;
            params.state = mapObject.getState();
            addTransaction(new TMove(mapObject,params));
         }
      }
      
      override protected function getCurrentImage() : ItemImage
      {
         var imageName:String = null;
         var image:ItemImage = null;
         if(m_item != null)
         {
            switch(m_direction)
            {
               case Constants.DIRECTION_SE:
               case Constants.DIRECTION_SW:
                  imageName = "frt_";
                  break;
               case Constants.DIRECTION_NE:
               case Constants.DIRECTION_NW:
               default:
                  imageName = "bk_";
            }
            switch(this.m_petState)
            {
               case STATE_TICKLE:
               case STATE_ROLLOVER:
               case STATE_PLAYDEAD:
               case STATE_SHAKE:
               case STATE_FOLLOW:
               case STATE_SIT:
                  imageName += this.m_petState;
                  break;
               default:
                  imageName += STATE_SIT;
            }
            if(this.isAdult())
            {
               imageName += "_adult";
            }
            image = m_item.getCachedImage(postProcessImageName(imageName));
         }
         return image;
      }
      
      override protected function updateToolTipText() : void
      {
         var isAdult:Boolean = false;
         var toolTipStr:String = null;
         var toolTipContent:String = null;
         var minute:Number = NaN;
         var hour:Number = NaN;
         var timeToFeed:String = null;
         var totalTreats:int = 0;
         var toolTip:String = null;
         if(isHighlighted())
         {
            if(this.petName.length > 0 && this.petName != "")
            {
               isAdult = this.isAdult();
               if(isAdult && 0 == this.m_kibbleFedCount)
               {
                  toolTip = ZLocUtils.t("Dialogs","PetToolTipAdultLevel",{
                     "petName":this.petName,
                     "quantity":this.petLevel
                  });
               }
               else
               {
                  toolTipStr = this.isMale() ? "PetToolTipMale" : "PetToolTipFemale";
                  toolTipContent = this.petName;
                  toolTip = ZLocUtils.t("Dialogs",toolTipStr,{"tooltip":toolTipContent}) + "\n";
                  if(!Global.worldManager.isVisiting())
                  {
                     if(this.m_isCash && !isAdult)
                     {
                        toolTip += ZLocUtils.t("Dialogs","PetToolTipKibbleCash",{"quantity":Math.min(this.m_daysSincePurchase,PET_DAYS_TO_GROW)});
                     }
                     else if(this.petLevel < PetConfig.getMaxLevel())
                     {
                        if(isAdult)
                        {
                           totalTreats = PetConfig.getTotalTreatsToLevel(this.getNextLevel());
                           toolTip += ZLocUtils.t("Dialogs","PetToolTipAdultFedTimes",{
                              "quantity":this.m_kibbleFedCount,
                              "quantityTotal":totalTreats
                           }) + "\n";
                        }
                        else
                        {
                           toolTip += ZLocUtils.t("Dialogs","PetToolTipKibbleCoin",{"quantity":this.m_kibbleFedCount}) + "\n";
                        }
                        minute = this.getMinutesUntilHungryAgain() % 60;
                        hour = this.getHoursUntilHungryAgain();
                        if(!this.m_isHungry || Boolean(Math.round(GlobalEngine.currentTime * 2 / FarmGameUtil.NUM_MSECS_IN_SECOND) % 2))
                        {
                           timeToFeed = FarmGameUtil.numberToStringPadZeros(hour) + ":" + FarmGameUtil.numberToStringPadZeros(minute);
                        }
                        else
                        {
                           timeToFeed = "         ";
                        }
                        if(this.m_isHungry)
                        {
                           toolTip += ZLocUtils.t("Dialogs","PetToolTipHungry",{"timeUnit":timeToFeed});
                        }
                        else if(this.m_kibbleFedCount < PET_DAYS_TO_GROW)
                        {
                           toolTip += ZLocUtils.t("Dialogs","PetToolTipNotHungry",{"timeUnit":timeToFeed});
                        }
                     }
                  }
               }
            }
            else
            {
               toolTip = ZLocUtils.tk_pk_asTitle(m_item.friendlyName);
            }
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      private function getMinutesUntilHungryAgain() : Number
      {
         return Math.floor(this.m_timeUntilHungryAgain / FarmGameUtil.NUM_MSECS_IN_MINUTE);
      }
      
      private function getHoursUntilHungryAgain() : Number
      {
         return Math.floor(this.m_timeUntilHungryAgain / FarmGameUtil.NUM_MSECS_IN_HOUR);
      }
      
      public function isMale() : Boolean
      {
         return this.m_petGender == Pet.GENDER_MALE;
      }
      
      public function set petGender(petGender:Number) : void
      {
         this.m_petGender = petGender;
      }
      
      public function get petGender() : Number
      {
         return this.m_petGender;
      }
      
      public function set petName(petName:String) : void
      {
         this.m_petName = petName;
      }
      
      public function get petName() : String
      {
         return this.m_petName;
      }
      
      public function get petLevel() : int
      {
         return this.m_petLevel;
      }
      
      public function set isCash(isCash:Boolean) : void
      {
         this.m_isCash = isCash;
      }
      
      override public function set animalState(state:String) : void
      {
         this.m_petState = state;
         m_hideArrow = true;
         switch(this.m_petState)
         {
            case Pet.STATE_TICKLE:
            case Pet.STATE_ROLLOVER:
            case Pet.STATE_PLAYDEAD:
            case Pet.STATE_SHAKE:
               this.m_petTrickTime = GlobalEngine.currentTime + PetConfig.getTrickAnimationLength(this.m_petState);
               break;
            case Pet.STATE_RUNAWAY:
               this.onPetRunAway();
               break;
            case Pet.STATE_SIT:
            default:
               this.m_petBubbleTime = GlobalEngine.currentTime + Pet.THOUGHT_BUBBLE_DELAY;
         }
         reloadImage();
      }
      
      public function isAdult() : Boolean
      {
         var isOldEnough:Boolean = false;
         var hasFedEnoughKibble:Boolean = false;
         var isAdult:Boolean = false;
         if(this.petLevel > 0)
         {
            isAdult = true;
         }
         else
         {
            isOldEnough = this.m_daysSincePurchase >= PET_DAYS_TO_GROW;
            hasFedEnoughKibble = this.m_isCash || this.m_kibbleFedCount >= PET_DAYS_TO_GROW;
            isAdult = isOldEnough && hasFedEnoughKibble;
            if(isAdult)
            {
               this.m_petLevel = 1;
               this.m_kibbleFedCount = 0;
            }
         }
         return isAdult;
      }
      
      public function get hasUserSeenAdult() : Boolean
      {
         return this.m_hasUserSeenAdult;
      }
      
      override public function detach() : void
      {
         if(this.m_petState != Pet.STATE_RUNAWAY)
         {
            Global.player.removeLimitedItem(this.m_item.name);
         }
         super.detach();
      }
      
      public function isHungry() : Boolean
      {
         if(this.m_kibbleFedCount >= PET_DAYS_TO_GROW)
         {
            this.m_kibbleFedCount = PET_DAYS_TO_GROW;
            this.m_isHungry = false;
         }
         return this.m_isHungry;
      }
      
      public function onFed() : void
      {
         if(this.isHungry())
         {
            m_timeSinceGrowUpdate = GROW_UPDATE_RATE;
            this.m_lastFedTime = Global.worldTime;
            ++this.m_kibbleFedCount;
            if(this.isAdult() && 1 == this.m_kibbleFedCount)
            {
               this.m_levelStartTime = Global.worldTime;
            }
            m_arrow = null;
            this.m_isHungry = false;
            this.updateFedState();
            if(!this.updateLevel())
            {
               this.startTrickAnimation(STATE_TICKLE);
            }
            if(this.petLevel < PetConfig.getMaxLevel())
            {
               this.checkFoodCountOnFed();
            }
         }
      }
      
      public function updateLevel() : Boolean
      {
         var numTreatsNeeded:int = 0;
         var trickName:String = null;
         var updated:Boolean = false;
         if(this.isAdult() && this.petLevel < PetConfig.getMaxLevel())
         {
            if(0 == this.petLevel)
            {
               this.m_petLevel = 1;
               this.m_kibbleFedCount = 0;
               this.startTrickAnimation(STATE_TICKLE,this.displayReachedAdultMessage);
               updated = true;
            }
            else
            {
               numTreatsNeeded = PetConfig.getTotalTreatsToLevel(this.getNextLevel());
               if(this.m_kibbleFedCount >= numTreatsNeeded)
               {
                  ++this.m_petLevel;
                  this.m_kibbleFedCount = 0;
                  trickName = this.getCurrentLevelTrick();
                  if(PetConfig.isTrickAnimationOnly(trickName))
                  {
                     this.startTrickAnimation(trickName,this.displayLevelUpMessage);
                  }
                  else
                  {
                     this.startTrickAnimation(STATE_TICKLE,this.displayLevelUpMessage);
                  }
                  updated = true;
               }
            }
         }
         return updated;
      }
      
      private function getCurrentLevelTrick() : String
      {
         var trickName:String = null;
         if(this.m_petItem)
         {
            trickName = this.m_petItem.getLevelTrick(this.petLevel);
         }
         return trickName;
      }
      
      public function onRescue(timestamp:Number = 0) : void
      {
         m_timeSinceGrowUpdate = GROW_UPDATE_RATE;
         this.m_lastFedTime = timestamp;
         m_arrow = null;
         this.m_isHungry = false;
         this.updateFedState();
         this.checkFoodCountOnFed();
      }
      
      override public function onObjectDrop() : void
      {
         var item:FarmItem = null;
         super.onObjectDrop();
         if(this.m_petState == Pet.STATE_RUNAWAY)
         {
            this.animalState = Pet.STATE_SIT;
            item = Global.farmGameSettingsManager.getFarmItemByName(ITEM_PET_RESCUE);
            Global.player.cash -= item.cash;
            addTransaction(new TRescuePet(this),true);
         }
      }
      
      public function getAvailableFoodCount() : int
      {
         return Global.player.getGiftCountForItem(this.getPetFeedItemName());
      }
      
      public function checkFoodCountOnFed() : void
      {
         var foodCount:int = this.getAvailableFoodCount();
         if(foodCount <= 0)
         {
            if(this.m_timer != null)
            {
               this.m_timer.stop();
               this.m_timer = null;
            }
            this.m_timer = new Timer(Pet.THOUGHT_BUBBLE_DELAY,1);
            this.m_timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onDisplayAskForFoodTimer);
            this.m_timer.start();
         }
      }
      
      public function onDisplayAskForFoodTimer(event:TimerEvent) : void
      {
         if(this.m_timer)
         {
            this.m_timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onDisplayAskForFoodTimer);
            this.m_timer = null;
         }
         this.displayAskForFoodDialog();
      }
      
      public function displayAskForFoodDialog() : void
      {
         var dialogContent:String = null;
         var foodCount:int = this.getAvailableFoodCount();
         var askFoodTitle:String = null;
         var localizePostfix:String = this.isAdult() ? "Adult" : "";
         if(foodCount <= 0)
         {
            askFoodTitle = "OutOfPetFoodTitle" + localizePostfix;
            dialogContent = ZLocUtils.t("Dialogs","OutOfPetFoodContent" + localizePostfix);
         }
         else
         {
            askFoodTitle = "AskForMorePetFoodTitle" + localizePostfix;
            dialogContent = ZLocUtils.t("Dialogs","AskForMorePetFoodContent" + localizePostfix,{"quantity":foodCount});
         }
         var contentMessage:String = "AskForMorePetFood" + (this.isMale() ? "Male" : "Female") + (this.m_isCash ? "Cash" : "Coin") + localizePostfix;
         dialogContent += " " + ZLocUtils.t("Dialogs",contentMessage,{((this.isMale() ? "male" : "female") + "_name"):this.petName});
         var dialog:GenericPopupTitleBig = new GenericPopupTitleBig(askFoodTitle,dialogContent,GenericPopup.TYPE_ACCEPTCANCEL,this.onAskForFood);
         dialog.setAcceptTextName("AskYourFriendsPetFood" + localizePostfix);
         UI.displayPopup(dialog,true,"askForPetFoodPopup",true);
      }
      
      private function onAskForFood(event:GenericPopupTitleBigEvent) : void
      {
         var currentTime:Number = NaN;
         var deltaTime:Number = NaN;
         var fetchFrequency:Number = NaN;
         var petItem:FarmItem = null;
         var petItemName:String = null;
         var petItemNameCashIndex:int = 0;
         var feedBundle:String = null;
         var imageUrl:String = null;
         var params:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            currentTime = GlobalEngine.serverTime / 1000;
            deltaTime = currentTime - Global.player.getFeatureLastShown(Pet.PET_ASK_FRIENDS_FREQ_KEY);
            fetchFrequency = Global.farmGameSettingsManager.getNumber("petAskFriendsFrequency",86400);
            if(deltaTime >= fetchFrequency)
            {
               petItem = getItem();
               petItemName = petItem.name;
               petItemNameCashIndex = petItemName.lastIndexOf("_cash");
               if(petItemNameCashIndex != -1)
               {
                  petItemName = petItemName.substring(0,petItemNameCashIndex);
               }
               addTransaction(new TPetItemRequestEvent(this,this.getPetFeedItemName()));
               if(this.isAdult())
               {
                  feedBundle = "PetsAskForMoreTreats";
                  imageUrl = "assets/hud/treat.png";
               }
               else
               {
                  feedBundle = "PetsAskForMoreKibble";
                  imageUrl = "assets/newsfeed/kibble_" + petItemName + ".png";
               }
               params = new Object();
               params.images = [{
                  "src":Global.getAssetURL(imageUrl),
                  "href":"{SN_APP_URL}gifts.php?giftRecipient=" + Global.player.snUser.uid
               }];
               params.pet_name = this.petName;
               GlobalEngine.socialNetwork.publishFeedStory(feedBundle,params,[],false);
               Global.player.setFeatureLastShown(Pet.PET_ASK_FRIENDS_FREQ_KEY,currentTime,true);
            }
            else
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","PetFriendRewardDailyLimit"));
            }
         }
      }
      
      override public function canUseConsumable(consumable:String) : Boolean
      {
         var canUse:Boolean = false;
         if(this.isHungry() && !this.m_isFollowing)
         {
            canUse = this.getPetFeedItemName() == consumable;
         }
         return canUse;
      }
      
      private function getPetFeedItemName() : String
      {
         var itemName:String = null;
         if(this.isAdult())
         {
            itemName = FEED_ITEM_ADULT;
         }
         else
         {
            itemName = FEED_ITEM_NON_ADULT;
         }
         return itemName;
      }
      
      private function onPetRunAway() : void
      {
         if(!Global.worldManager.isVisiting())
         {
            if(!this.isRescue)
            {
               PetManager.getInstance().addRunawayPet(this);
               this.m_petReminderPopupDelayTime = GlobalEngine.currentTime + Pet.RESCUE_REMINDER_DELAY;
            }
         }
         setVisible(false);
      }
      
      private function showBubble() : void
      {
         m_hideArrow = false;
         reloadImage();
      }
      
      override public function postDisableMove() : void
      {
         if(this.m_petState == Pet.STATE_RUNAWAY && !this.isRescue)
         {
            this.m_allowFollow = false;
            setVisible(false);
         }
         this.isRescue = false;
      }
      
      public function set isRescue(rescue:Boolean) : void
      {
         this.m_isRescue = rescue;
      }
      
      public function get isRescue() : Boolean
      {
         return this.m_isRescue;
      }
      
      public function showPetHungryReminder() : void
      {
         var title:String = null;
         var message:String = null;
         var hoursLeft:Number = NaN;
         if(this.petLevel < PetConfig.getMaxLevel())
         {
            title = ZLocUtils.t("Dialogs","PetHungryReminderTitle",{"pet":ZLocUtils.tn(this.petName,this.isMale() ? ZLocUtils.MASC : ZLocUtils.FEM)});
            message = ZLocUtils.t("Dialogs","PetHungryReminderMessage",{"quantity":this.getHoursUntilHungryAgain()});
            hoursLeft = this.getHoursUntilHungryAgain();
            if(hoursLeft > 0)
            {
               message = ZLocUtils.t("Dialogs","PetHungryReminderMessage",{"quantity":hoursLeft});
            }
            else
            {
               message = ZLocUtils.t("Dialogs","PetHungryReminderMessageMinutes",{"quantity":this.getMinutesUntilHungryAgain()});
               ToasterManager.getInstance().add(new GenericCustomAdToaster(title,message,REMINDER_POPUP_DURATION,this.onHungryReminderClick));
            }
         }
      }
      
      public function onHungryReminderClick() : void
      {
         this.centerOn();
      }
      
      public function get kibbleFedCount() : Number
      {
         return this.m_kibbleFedCount;
      }
      
      public function getNextLevel() : int
      {
         return this.petLevel + 1;
      }
      
      private function displayReachedAdultMessage() : void
      {
         var isMale:Boolean = this.isMale();
         IdleTaskQueue.getInstance().addTask(new AdultPetTask(this.petName,isMale));
      }
      
      private function displayLevelUpMessage() : void
      {
         var messageKey:String = null;
         var message:String = null;
         var dialog:GenericPopupTitleBig = null;
         var trickName:String = PetConfig.getTrickFriendlyName(this.getCurrentLevelTrick());
         if(PetConfig.getMaxLevel() == this.petLevel)
         {
            if(this.isMale())
            {
               message = ZLocUtils.t("Dialogs","PetLevelUpFinalMessageMale",{
                  "male_name":this.petName,
                  "trick":trickName
               });
            }
            else
            {
               message = ZLocUtils.t("Dialogs","PetLevelUpFinalMessageFemale",{
                  "female_name":this.petName,
                  "trick":trickName
               });
            }
            dialog = new GenericPopupTitleBig("Congratulations",message,GenericPopup.TYPE_OK);
         }
         else
         {
            if(this.isMale())
            {
               message = ZLocUtils.t("Dialogs","PetLevelUpMessageMale",{
                  "male_name":this.petName,
                  "trick":trickName
               });
            }
            else
            {
               message = ZLocUtils.t("Dialogs","PetLevelUpMessageFemale",{
                  "female_name":this.petName,
                  "trick":trickName
               });
            }
            dialog = new GenericPopupTitleBig("Congratulations",message,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyTreats);
            dialog.setAcceptTextName("BuyTreats");
         }
         UI.displayPopup(dialog);
      }
      
      public function displayLevelProgressReset() : void
      {
         var message:String = "";
         if(this.isMale())
         {
            message = ZLocUtils.t("Dialogs","PetForgotTrickMessageMale",{
               "male_name":this.petName,
               "male_name_same":this.petName
            });
         }
         else
         {
            message = ZLocUtils.t("Dialogs","PetForgotTrickMessageFemale",{
               "female_name":this.petName,
               "female_name_same":this.petName
            });
         }
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_OK,null,Global.getAssetURL(FORGOT_TRICKS_ICON));
         UI.displayPopup(dialog);
         Global.player.setFeatureLastShown("show_reset_dialog_" + this.m_petName,GlobalEngine.currentTime,true);
      }
      
      private function onBuyTreats(event:GenericPopupTitleBigEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            UI.displayMarketDialog("petsReachAdultBuyTreat","animal",null,"pets");
         }
      }
      
      override protected function getImageScaleFactor() : Number
      {
         var result:Number = 0;
         if(this.isAdult())
         {
            if(this.m_petItem)
            {
               result = this.m_petItem.imageScaleAdult;
            }
         }
         else
         {
            result = super.getImageScaleFactor();
         }
         return result;
      }
      
      private function isCollingWithObjects() : Boolean
      {
         return Global.world.checkCollision(this.getPosition().x,this.getPosition().y,this.getPosition().x + this.getSize().x,this.getPosition().y + this.getSize().y,[this],null,Constants.WORLDOBJECT_ALL,null,false);
      }
      
      private function runTowardsWorldObject() : void
      {
         var consumableName:String = null;
         var consumableItem:FarmItem = null;
         var harvestType:String = null;
         var harvestCount:Number = NaN;
         var animalObject:SimpleHarvestableResource = null;
         var petToObjectDistance:Number = NaN;
         var maxPetToObjectDistance:Number = NaN;
         var trickName:String = this.m_petItem.getLevelTrick(this.petLevel);
         var currentPos:Vector3 = getPosition();
         var objSize:Vector3 = getSize();
         var walkPos:Vector3 = null;
         var allowRunning:Boolean = true;
         if(trickName == Pet.PET_TRICK_HARVEST)
         {
            consumableName = this.m_petItem.getTrickConsumable(this.petLevel);
            consumableItem = Global.farmGameSettingsManager.getFarmItemByName(consumableName);
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               harvestType = consumableItem.getStringFromDataSource("harvestType");
               harvestCount = consumableItem.getNumberFromDataSource("harvestCount");
            }
            else
            {
               harvestType = consumableItem.xml.harvestType;
               harvestCount = Number(consumableItem.xml.harvestCount);
            }
            if(harvestType != null)
            {
               animalObject = this.getRandomHarvestableAnimals(harvestType,harvestCount);
               if(animalObject)
               {
                  walkPos = animalObject.getPosition();
               }
               else
               {
                  allowRunning = false;
               }
            }
            else
            {
               walkPos = Global.player.avatar.getPosition();
            }
         }
         else
         {
            walkPos = Global.player.avatar.getPosition();
         }
         if(allowRunning)
         {
            petToObjectDistance = walkPos.subtract(currentPos).length();
            maxPetToObjectDistance = Global.player.avatar.isWalking() ? PET_AVATAR_MIN_DISTANCE_MOVING : PET_AVATAR_MIN_DISTANCE;
            if(petToObjectDistance > maxPetToObjectDistance)
            {
               this.m_currentPos = getPosition();
               m_WalkSpeed = Global.farmGameSettingsManager.getNumber("animalFollowSpeed");
               this.m_isPerformingTrick = walkTo(walkPos.x,walkPos.y,PET_AVATAR_MIN_DISTANCE);
               this.m_isReturningFromTrick = false;
               if(this.m_isPerformingTrick)
               {
                  this.createFollowPlaceHolder(this.m_currentPos);
                  this.animalState = Pet.STATE_FOLLOW;
               }
            }
         }
      }
      
      private function runAround() : void
      {
         var dist:Number = Global.farmGameSettingsManager.getNumber("petFetchRunMaxDistance",10);
         var objSize:Vector3 = getSize();
         var walkPos:Vector3 = getPosition().clone();
         walkPos.x += Utilities.randBetween(-dist,dist);
         walkPos.y += Utilities.randBetween(-dist,dist);
         walkPos.x = Math.round(Utilities.clamp(walkPos.x,0,Global.world.getGridWidth() - objSize.x));
         walkPos.y = Math.round(Utilities.clamp(walkPos.y,0,Global.world.getGridHeight() - objSize.y));
         var positionValid:Boolean = !Global.world.checkCollision(walkPos.x,walkPos.y,walkPos.x + objSize.x,walkPos.y + objSize.y,[this],null,Constants.WORLDOBJECT_ALL,null,false);
         this.m_currentPos = getPosition();
         if(positionValid)
         {
            m_WalkSpeed = Global.farmGameSettingsManager.getNumber("animalFollowSpeed");
            this.m_isPerformingTrick = walkTo(walkPos.x,walkPos.y);
            this.m_isReturningFromTrick = false;
            this.createFollowPlaceHolder(this.m_currentPos);
            this.animalState = Pet.STATE_FOLLOW;
         }
      }
      
      private function getRandomHarvestableAnimals(harvestType:String, harvestCount:Number) : SimpleHarvestableResource
      {
         var animalObject:SimpleHarvestableResource = null;
         var allObjects:Array = null;
         var totalObjects:Number = NaN;
         var harvestItem:FarmItem = null;
         var harvestObject:SimpleHarvestableResource = null;
         var harvestables:Array = Global.world.getObjectsByClass(Animal);
         var isInDataSourceExperiment:Boolean = FarmGameSettingsManager.isInDataSourceExperiment();
         var consumableItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_petItem.getTrickConsumable(this.petLevel));
         if(isInDataSourceExperiment)
         {
            harvestType = consumableItem.getStringFromDataSource("harvestType");
            harvestCount = consumableItem.getNumberFromDataSource("harvestCount");
         }
         else
         {
            harvestType = consumableItem.xml.harvestType;
            harvestCount = Number(consumableItem.xml.harvestCount);
         }
         if(harvestType != null)
         {
            allObjects = harvestables;
            harvestables = [];
            totalObjects = 0;
            for each(harvestObject in allObjects)
            {
               harvestItem = harvestObject.getItem();
               if(Boolean(harvestItem) && harvestObject.isHarvestable())
               {
                  if(isInDataSourceExperiment)
                  {
                     if(harvestCount > 0)
                     {
                        if(!harvestItem.getBoolFromDataSource("ignorePetHarvest"))
                        {
                           harvestables.push(harvestObject);
                           if(totalObjects++ >= harvestCount - 1)
                           {
                              break;
                           }
                        }
                     }
                     else if(harvestItem.getStringFromDataSource("name").indexOf(harvestType,0) == 0)
                     {
                        if(!harvestItem.getBoolFromDataSource("ignorePetHarvest"))
                        {
                           harvestables.push(harvestObject);
                        }
                     }
                  }
                  else if(harvestItem.xml)
                  {
                     if(harvestCount > 0)
                     {
                        if(harvestItem.xml.@ignorePetHarvest.toString() == "" || harvestItem.xml.@ignorePetHarvest.toString() == "false")
                        {
                           harvestables.push(harvestObject);
                           if(totalObjects++ >= harvestCount - 1)
                           {
                              break;
                           }
                        }
                     }
                     else if(harvestItem.xml.@name.indexOf(harvestType,0) == 0)
                     {
                        if(harvestItem.xml.@ignorePetHarvest.toString() == "" || harvestItem.xml.@ignorePetHarvest.toString() == "false")
                        {
                           harvestables.push(harvestObject);
                        }
                     }
                  }
               }
            }
            if(harvestables.length > 0)
            {
               animalObject = harvestables.pop();
            }
         }
         return animalObject;
      }
      
      private function isFinalTrick() : Boolean
      {
         return this.petLevel == PetConfig.getMaxLevel();
      }
      
      private function onTrickRoundTrip() : void
      {
         this.removeFollowPlaceHolder();
         if(this.m_isReturningFromTrick)
         {
            this.m_isPerformingTrick = false;
            this.animalState = Pet.STATE_SIT;
         }
         else
         {
            this.m_isReturningFromTrick = true;
            walkTo(this.m_currentPos.x,this.m_currentPos.y);
            this.createFollowPlaceHolder(this.m_currentPos);
         }
      }
      
      private function createFollowPlaceHolder(pos:Vector3) : void
      {
         this.m_followPlaceHolder = createPlaceholder();
         if(this.m_followPlaceHolder)
         {
            this.m_followPlaceHolder.setPosition(pos.x,pos.y,pos.z);
            this.m_followPlaceHolder.attach();
         }
      }
      
      private function removeFollowPlaceHolder() : void
      {
         if(this.m_followPlaceHolder)
         {
            this.m_followPlaceHolder.detach();
            this.m_followPlaceHolder = null;
         }
      }
      
      override public function isDecoMoveSupported() : Boolean
      {
         return false;
      }
      
      override public function handleDecoMoveUnsupported() : void
      {
         this.move();
      }
      
      override public function isHarvestableByNeighbors() : Boolean
      {
         return false;
      }
   }
}

