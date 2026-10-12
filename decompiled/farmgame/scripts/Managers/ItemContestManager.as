package Managers
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.Experiments;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.*;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Transactions.TransactionWithCallBack;
   import ZLocalization.Utilities;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   
   public class ItemContestManager
   {
      
      public static const FEATURE_NAME:String = "Contests";
      
      private static const FEATUREOPTIONS_CONTEST_NAME:String = "itemContests";
      
      public static const EVENTLISTENER_CONTEST_TYPE:String = "contests_update";
      
      public static const ICON_NAME:String = "treetopFair";
      
      public static const TOASTER_URL:String = "assets/dialogs/FV_Contests_toaster.swf";
      
      private static var m_instance:ItemContestManager = null;
      
      public static var m_initialized:Boolean = false;
      
      private var m_dialogListener:Boolean = false;
      
      private var m_contests:Array;
      
      private var m_currContest:int = -1;
      
      private var m_lostMulch:Number = 0;
      
      private var m_windowClass:Class;
      
      private var m_windowAsset:String;
      
      private var m_contestName:String;
      
      private var m_mulchUpdating:Boolean = false;
      
      private var m_featureOptions:Object;
      
      private var m_gameSettings:XML;
      
      public function ItemContestManager(singletonEnforcer:SingletonEnforcer)
      {
         super();
         if(singletonEnforcer == null)
         {
            throw new Error("Error: Instantiation failed: Use ItemContestManager.getInstance() instead of new.");
         }
      }
      
      public static function getInstance() : ItemContestManager
      {
         if(m_instance == null)
         {
            m_instance = new ItemContestManager(new SingletonEnforcer());
         }
         return m_instance;
      }
      
      public static function registerFeature() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized("contests",lazyLoadDisplayDialog);
      }
      
      public static function lazyLoadDisplayDialog() : void
      {
         ItemContestManager.getInstance().displayDialog();
      }
      
      public static function inMainExperiment() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CONTESTS) == 2 || Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CONTESTS) == 3;
      }
      
      public static function isInstanciated() : Boolean
      {
         return ItemContestManager.m_initialized && ItemContestManager.m_instance.m_contests != null;
      }
      
      public function init() : void
      {
         if(inMainExperiment())
         {
            if(!m_initialized)
            {
               m_initialized = this.dataParsing();
               if(m_initialized)
               {
                  Global.world.addEventListener(ItemContestManager.EVENTLISTENER_CONTEST_TYPE,this.mulchFound);
                  Global.hud.rightSideIconQueue.addIcon(ItemContestManager.ICON_NAME,DynamicIconQueue.ADD_BY_PRIORITY,null,false);
               }
            }
         }
      }
      
      private function dataParsing() : Boolean
      {
         var count:int = 0;
         var attributes:XML = null;
         var contest:XML = null;
         var validContest:Boolean = false;
         var success:Boolean = false;
         this.m_featureOptions = FeatureOptionsManager.getInstance().getFeatureOption(ItemContestManager.FEATUREOPTIONS_CONTEST_NAME);
         if(this.m_featureOptions == null)
         {
            this.m_featureOptions = {};
            this.m_featureOptions["contests"] = {};
            this.m_featureOptions["mulches"] = {};
         }
         this.m_gameSettings = Global.farmGameSettingsManager.getFeatureXML(ItemContestManager.FEATUREOPTIONS_CONTEST_NAME);
         if(this.m_gameSettings != null)
         {
            this.m_contests = Utilities.xmlListToArray(this.m_gameSettings.contests.contest);
            for(count = 0; count < this.m_contests.length; count++)
            {
               contest = this.m_contests[count];
               validContest = true;
               if(contest.hasOwnProperty("prereqs"))
               {
                  validContest = PrerequisiteUtility.arePrerequisitesMet(PrerequisiteUtility.parseXmlNodePrereqs(contest.child("prereqs").prereq));
               }
               if(validContest)
               {
                  this.m_currContest = count;
                  break;
               }
            }
            this.m_contestName = this.m_contests[this.m_currContest].attribute("name");
            attributes = this.m_gameSettings.UI.dialog[0] as XML;
            this.m_windowClass = getDefinitionByName(attributes.attribute("className")) as Class;
            this.m_windowAsset = attributes.attribute("path");
            success = true;
         }
         return success;
      }
      
      public function displayDialog(event:Event = null) : void
      {
         if(event != null)
         {
            FarmStatsManager.count(ItemContestManager.FEATURE_NAME,"click_toaster");
         }
         if(m_initialized)
         {
            this.showWindow();
         }
         else if(!this.m_dialogListener)
         {
            this.m_dialogListener = true;
            Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferDialog);
         }
      }
      
      private function deferDialog(event:Event) : void
      {
         Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferDialog);
         this.m_dialogListener = false;
         this.showWindow();
      }
      
      private function showWindow() : void
      {
         FarmStatsManager.count(ItemContestManager.FEATURE_NAME,"open_ui");
         UI.displayPopup(new this.m_windowClass(this.m_windowAsset),true,"Contests",true);
      }
      
      public function getCurrentContestName() : String
      {
         return this.m_contestName;
      }
      
      public function getMulchLost() : Number
      {
         return this.m_lostMulch;
      }
      
      public function getMulchMax() : Number
      {
         return Number(this.m_gameSettings.mulches.attribute("itemCapacity"));
      }
      
      public function updateMulches(callback:Function) : void
      {
         if(!this.m_mulchUpdating)
         {
            this.m_mulchUpdating = true;
            TransactionManager.addTransaction(new TransactionWithCallBack("ItemContestService.getCurrentMulchTypes",ZCacheUtil.applyPartial(this.updateMulchesCallback,this,[callback])),true);
         }
      }
      
      public function updateMulchesCallback(callback:Function, result:Object) : void
      {
         if(Boolean(result.success) && Boolean(result["data"]))
         {
            this.m_featureOptions["contests"] = result["data"];
            callback.call();
         }
         this.m_mulchUpdating = false;
      }
      
      public function mulchFound(mulchInfo:Object) : void
      {
         var mulch:FarmItem = null;
         var mulchObject:Object = mulchInfo.data.mulches;
         var mulchName:String = mulchObject.name;
         if(mulchObject.stored)
         {
            if(this.m_featureOptions.mulches.hasOwnProperty(mulchName))
            {
               ++this.m_featureOptions.mulches[mulchName].amount;
            }
            else
            {
               this.m_featureOptions.mulches[mulchName] = {"amount":1};
            }
            mulch = Global.farmGameSettingsManager.getFarmItemByName(mulchName);
            Global.player.avatar.displayStatus(ZLocUtils.t("Dialogs","mulchFloatyText",{"mulch":ZLocUtils.tk_pk_asTitle(mulch.friendlyName)}),mulch.icon);
         }
      }
      
      public function hasCompletedAllContests() : Boolean
      {
         var count:int = 0;
         var contest:XML = null;
         var name:String = null;
         var numTiers:int = 0;
         var contestFeatureOptions:Object = null;
         var division:Object = null;
         var result:Boolean = true;
         if(Boolean(this.m_contests) && Boolean(this.m_featureOptions.contests))
         {
            loop0:
            for(count = 0; count < this.m_contests.length; count++)
            {
               contest = this.m_contests[count];
               name = contest.attribute("name");
               numTiers = parseInt(contest.attribute("tierCount"));
               contestFeatureOptions = this.m_featureOptions.contests[name];
               if(!name || !numTiers || !contestFeatureOptions || !contestFeatureOptions.divisions)
               {
                  result = false;
                  break;
               }
               for each(division in contestFeatureOptions.divisions)
               {
                  if(division["tier"] < numTiers)
                  {
                     result = false;
                     break loop0;
                  }
               }
            }
         }
         else
         {
            result = false;
         }
         return result;
      }
      
      public function getPrize() : Object
      {
         var prizes:XMLList = null;
         var prizeCode:String = null;
         var cashReward:Number = NaN;
         var tierLevel:Number = this.convertFrontendTierToBackendTier(this.getPrizeLevel());
         var result:Object = null;
         if(this.m_contests[this.m_currContest].tiers.tier[tierLevel])
         {
            prizes = this.m_contests[this.m_currContest].tiers.tier[tierLevel].rewards.reward;
            prizeCode = prizes[0].attribute("value");
            cashReward = 0;
            if(prizes[1])
            {
               cashReward = Number(prizes[1].attribute("value"));
            }
            result = {
               "item":Global.farmGameSettingsManager.getFarmItemByCode(prizeCode),
               "cash":cashReward
            };
         }
         return result;
      }
      
      public function moveUpTier(contestant:String, mulch:String, nextMulch:String, startTime:Number, duration:Number) : void
      {
         var divisionData:Object = this.m_featureOptions.contests[this.m_contestName].divisions[this.getDivisionByContestant(contestant).attribute("name")];
         divisionData.tier += 1;
         var mulchData:Object = divisionData.mulch;
         mulchData.curr = mulch;
         mulchData.next = nextMulch;
         mulchData.amount = 0;
         mulchData.start = startTime;
         mulchData.duration = duration;
         divisionData.shine = true;
      }
      
      public function loseMulch(contestant:String) : void
      {
         var mulchData:Object = this.m_featureOptions.contests[this.m_contestName].divisions[this.getDivisionByContestant(contestant).attribute("name")].mulch;
         this.m_lostMulch = mulchData.amount;
         mulchData.amount = 0;
      }
      
      public function getMulch(contestant:String) : String
      {
         var mulchData:Object = this.m_featureOptions.contests[this.m_contestName].divisions[this.getDivisionByContestant(contestant).attribute("name")].mulch;
         return mulchData.curr;
      }
      
      public function payToSaveMulch(contestant:String, callback:Function, payOnLose:Number, isAccept:Boolean) : void
      {
         var divisionName:String = null;
         if(isAccept && Global.player.cash >= payOnLose)
         {
            Global.player.cash -= payOnLose;
            divisionName = m_instance.getDivisionByContestant(contestant).attribute("name");
            this.m_featureOptions.contests[this.m_contestName].divisions[divisionName].mulch.amount = this.m_lostMulch;
            this.m_lostMulch = 0;
            TransactionManager.addTransaction(new TransactionWithCallBack("ItemContestService.buybackMulch",null,this.m_contestName,divisionName,payOnLose),true);
         }
         else
         {
            UI.showMessage(ZLocUtils.t("Dialogs","NoCash"));
         }
         callback.call();
      }
      
      public function payToWin(contestant:String, payOnLose:Number, callback:Function) : void
      {
         Global.player.cash -= payOnLose;
         var divisionName:String = m_instance.getDivisionByContestant(contestant).attribute("name");
         var tier:Number = Number(this.m_featureOptions.contests[this.m_contestName].divisions[divisionName].tier);
         TransactionManager.addTransaction(new TransactionWithCallBack("ItemContestService.payForWin",callback,this.m_contestName,divisionName,tier,payOnLose),true);
      }
      
      public function getPrizeLevel(itemName:String = "", contestName:String = "") : Number
      {
         var division:XML = null;
         var divisionName:String = null;
         var divisions:Object = null;
         var key:String = null;
         var tier:Number = NaN;
         var result:Number = -1;
         var contest:String = contestName == "" ? this.m_contestName : contestName;
         if(Boolean(this.m_featureOptions) && Boolean(this.m_featureOptions.hasOwnProperty("contests")) && Boolean(this.m_featureOptions.contests.hasOwnProperty(contest)))
         {
            if(itemName != "")
            {
               division = this.getDivisionByContestant(itemName);
               divisionName = "";
               if(division == null)
               {
                  divisionName = itemName;
               }
               else
               {
                  divisionName = division.attribute("name");
               }
               result = this.convertBackendTierToFrontendTier(Number(this.m_featureOptions.contests[contest].divisions[divisionName].tier));
            }
            else
            {
               divisions = this.m_featureOptions.contests[contest].divisions as Object;
               for(key in divisions)
               {
                  tier = this.convertBackendTierToFrontendTier(Number(divisions[key].tier));
                  if(result < tier)
                  {
                     result = tier;
                  }
               }
            }
         }
         return result;
      }
      
      public function convertBackendTierToFrontendTier(beTier:Number) : Number
      {
         var tierCount:Number = Number(this.m_contests[this.m_currContest].attribute("tierCount"));
         return tierCount - beTier;
      }
      
      public function convertFrontendTierToBackendTier(feTier:Number) : Number
      {
         var tierCount:Number = Number(this.m_contests[this.m_currContest].attribute("tierCount"));
         return tierCount - feTier;
      }
      
      public function getItemsForContest() : Array
      {
         var contestData:Object = null;
         var key:String = null;
         var itemInfo:Object = null;
         var mulch:Object = null;
         var expiring:Number = NaN;
         var tier:String = null;
         var item:XML = null;
         var shouldShine:Boolean = false;
         var curr:String = null;
         var amount:String = null;
         var divisions:XMLList = null;
         var division:XML = null;
         var divisionAnimal:XML = null;
         var firstDuration:Number = NaN;
         var startTime:Number = NaN;
         var duration:Number = NaN;
         var result:Array = [];
         if(this.m_featureOptions.hasOwnProperty("contests") && Boolean(this.m_featureOptions.contests.hasOwnProperty(this.m_contestName)))
         {
            contestData = this.m_featureOptions.contests[this.m_contestName].divisions;
            for(key in contestData)
            {
               itemInfo = contestData[key];
               mulch = itemInfo.mulch;
               expiring = 0;
               if(mulch != null && mulch.duration != 0)
               {
                  expiring = mulch.start + mulch.duration;
               }
               tier = itemInfo.tier;
               if(this.convertBackendTierToFrontendTier(Number(tier)) == 0)
               {
                  tier = (Number(tier) - 1).toString();
                  expiring = 0;
               }
               item = this.m_contests[this.m_currContest].divisions.division.(attribute("name") == key).items.item[tier];
               shouldShine = false;
               if(itemInfo.hasOwnProperty("shine"))
               {
                  shouldShine = Boolean(itemInfo.shine);
               }
               itemInfo.shine = false;
               curr = "";
               amount = "";
               if(mulch != null)
               {
                  curr = mulch.curr;
                  amount = mulch.amount;
               }
               result.push({
                  "itemName":item.attribute("name"),
                  "mulch":curr,
                  "mulchOwned":amount,
                  "mulchNeeded":item.attribute("mulchNeeded"),
                  "expiring":expiring,
                  "shine":shouldShine
               });
            }
         }
         else
         {
            if(!this.m_featureOptions.hasOwnProperty("contests"))
            {
               this.m_featureOptions["contests"] = {};
            }
            if(!this.m_featureOptions.hasOwnProperty("mulches"))
            {
               this.m_featureOptions["mulches"] = {};
            }
            this.m_featureOptions.contests[this.m_contestName] = {};
            divisions = this.m_contests[this.m_currContest].divisions.division;
            for each(division in divisions)
            {
               divisionAnimal = division.items.item[0];
               firstDuration = Number(divisionAnimal.attribute("firstDuration"));
               startTime = GlobalEngine.serverTime;
               duration = 0;
               if(firstDuration == 0)
               {
                  duration = 0;
               }
               else
               {
                  duration = firstDuration + startTime;
               }
               result.push({
                  "itemName":divisionAnimal.attribute("name"),
                  "mulch":divisionAnimal.attribute("firstMulch"),
                  "mulchOwned":0,
                  "mulchNeeded":divisionAnimal.attribute("mulchNeeded"),
                  "expiring":divisionAnimal.attribute("firstDuration")
               });
               if(!this.m_featureOptions.contests.hasOwnProperty(this.m_contestName) || !this.m_featureOptions.contests[this.m_contestName].hasOwnProperty("divisions"))
               {
                  this.m_featureOptions.contests[this.m_contestName] = {"divisions":{}};
               }
               this.m_featureOptions.contests[this.m_contestName].divisions[division.attribute("name")] = {
                  "tier":0,
                  "mulch":{
                     "curr":divisionAnimal.attribute("firstMulch"),
                     "amount":0,
                     "start":startTime,
                     "duration":firstDuration
                  }
               };
            }
            TransactionManager.addTransaction(new TransactionWithCallBack("ItemContestService.initContest",ZCacheUtil.applyPartial(this.initContestCallback,this,[this.m_contestName]),this.m_contestName),true);
         }
         result.sort(this.sortItems);
         return result;
      }
      
      private function sortItems(a:Object, b:Object) : Number
      {
         var result:Number = 0;
         var aName:String = "";
         if(a.hasOwnProperty("itemName"))
         {
            aName = a.itemName;
         }
         var bName:String = "";
         if(b.hasOwnProperty("itemName"))
         {
            bName = b.itemName;
         }
         if(aName > bName)
         {
            result = 1;
         }
         else if(aName < bName)
         {
            result = -1;
         }
         return result;
      }
      
      public function initContestCallback(contestName:String, result:Object) : void
      {
         var key:String = null;
         for(key in result)
         {
            this.m_featureOptions.contests[contestName].divisions[key].mulch.next = result[key].mulch.next;
         }
      }
      
      public function getMulchAmount(mulchName:String) : Number
      {
         var result:Number = 0;
         if(this.m_featureOptions.hasOwnProperty("mulches") && Boolean(this.m_featureOptions.mulches.hasOwnProperty(mulchName)))
         {
            result = Number(this.m_featureOptions.mulches[mulchName].amount);
         }
         return result;
      }
      
      public function getTheme() : String
      {
         return (this.m_contests[this.m_currContest].frontEnd.background[0] as XML).attribute("path");
      }
      
      public function getPrizeTheme() : String
      {
         return (this.m_contests[this.m_currContest].frontEnd.prizeTheme[0] as XML).attribute("path");
      }
      
      public function getOverlayBG(large:Boolean) : String
      {
         var result:String = "";
         if(large)
         {
            result = (this.m_contests[this.m_currContest].frontEnd.overlayLarge[0] as XML).attribute("path");
         }
         else
         {
            result = (this.m_contests[this.m_currContest].frontEnd.overlaySmall[0] as XML).attribute("path");
         }
         return result;
      }
      
      public function setUpRibbon(ribbon:MovieClip, prizeLevel:Number) : void
      {
         var tierCount:Number = NaN;
         var frame:Number = 9;
         if(Boolean(this.m_contests) && Boolean(this.m_currContest >= 0) && this.m_currContest < this.m_contests.length)
         {
            tierCount = Number(this.m_contests[this.m_currContest].attribute("tierCount"));
            if(tierCount >= prizeLevel + 1)
            {
               frame = prizeLevel + 1;
            }
         }
         ribbon.gotoAndStop(frame);
         ribbon.visible = true;
      }
      
      public function enterContestant(contestant:String, callback:Function) : void
      {
         TransactionManager.addTransaction(new TransactionWithCallBack("ItemContestService.enterContest",callback,this.m_contestName,(this.getDivisionByContestant(contestant).attribute("name")[0] as XML).toString()),true);
      }
      
      public function feedMulch(contestant:String, mulch:String) : void
      {
         this.m_featureOptions.mulches[mulch].amount = (Number(this.m_featureOptions.mulches[mulch].amount) - 1).toString();
         var divisionName:String = this.getDivisionByContestant(contestant).attribute("name")[0];
         ++this.m_featureOptions.contests[this.m_contestName].divisions[divisionName].mulch.amount;
         TransactionManager.addTransaction(new TransactionWithCallBack("ItemContestService.feedContestant",this.feedMulchCallback,this.m_contestName,divisionName,mulch),false);
      }
      
      public function feedMulchCallback(result:Object) : void
      {
         if(result.success)
         {
         }
      }
      
      private function getDivisionByContestant(contestant:String) : XML
      {
         var result:XML = null;
         var division:XML = null;
         var matches:XMLList = null;
         var divisions:XMLList = this.m_contests[this.m_currContest].divisions.division;
         for each(division in divisions)
         {
            matches = division.descendants().(attribute("name") == contestant);
            if(matches.length() > 0)
            {
               result = division;
               break;
            }
         }
         return result;
      }
      
      public function getCategory(contestant:String) : Array
      {
         var item:XML = null;
         var items:XMLList = this.getDivisionByContestant(contestant).items.item;
         var result:Array = [];
         for each(item in items)
         {
            result.push({"contestant":item.attribute("name")});
         }
         return result;
      }
      
      public function isContestInitialized(contestName:String) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(this.m_featureOptions) && Boolean(this.m_featureOptions.hasOwnProperty("contests")) && Boolean(this.m_featureOptions.contests.hasOwnProperty(contestName)))
         {
            result = true;
         }
         return result;
      }
      
      public function getActiveContestNames() : Vector.<String>
      {
         var contest:XML = null;
         var validContest:Boolean = false;
         var result:Vector.<String> = new Vector.<String>();
         for(var count:int = 0; count < this.m_contests.length; count++)
         {
            contest = this.m_contests[count];
            validContest = true;
            if(contest.hasOwnProperty("prereqs"))
            {
               validContest = PrerequisiteUtility.arePrerequisitesMet(PrerequisiteUtility.parseXmlNodePrereqs(contest.child("prereqs").prereq));
            }
            if(validContest)
            {
               result.push(contest.attribute("name"));
            }
         }
         return result;
      }
      
      public function setSelectedContest(contestName:String) : Boolean
      {
         var contest:XML = null;
         var result:Boolean = false;
         for(var count:int = 0; count < this.m_contests.length; count++)
         {
            contest = this.m_contests[count];
            if(contest.attribute("name") == contestName)
            {
               this.m_currContest = count;
               this.m_contestName = contestName;
               result = true;
               break;
            }
         }
         return result;
      }
      
      public function getSelectedContestName() : String
      {
         return this.m_contestName;
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
