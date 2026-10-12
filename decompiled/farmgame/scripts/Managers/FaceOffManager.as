package Managers
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.FarmDynamicDialog;
   import Display.QueuedIcons.FaceOffQueuedIcon;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.FaceOffShareConsolation;
   import Widgets.Windows.FaceOffShareReward;
   import Widgets.Windows.FaceOffWindow;
   import ZLocalization.Utilities;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FaceOffManager
   {
      
      protected static var m_hudIcon:FaceOffQueuedIcon;
      
      protected static var m_config:Object;
      
      protected static var m_data:Object;
      
      protected static var m_rewards:Array;
      
      protected static var m_dialog:FarmDynamicDialog;
      
      protected static var m_acquiredAllItems:Boolean;
      
      private static const HUDICON_TOOLTIP_WIDTH:Number = 300;
      
      public static const DEFAULT_TRANSACTION_SERVICE:String = "FaceOffService";
      
      private static var m_countWindow:FaceOffWindow = null;
      
      public static const DEFAULT_FEATURE_NAME:String = "FaceOff";
      
      private static var m_instance:FaceOffManager = null;
      
      private var m_featureOptions:Object;
      
      private var m_gameSettings:XML;
      
      private var m_faceOffName:String;
      
      private var m_windowAsset:String;
      
      private var m_items:Array;
      
      private var m_picked:Array;
      
      private var m_dates:Array;
      
      private var m_numStages:int;
      
      private var m_featureLoadingTime:Number;
      
      private var m_currentStage:int;
      
      private var m_lastVoteTime:Number;
      
      private var m_voteInterval:Number;
      
      private var m_consolationPrizes:Array;
      
      private var m_numVotes:Object;
      
      private var m_numFriendVotes:Object;
      
      private var m_facePiles:Object;
      
      private var m_hudTimer:Timer;
      
      private var m_openingWindow:Boolean = false;
      
      public function FaceOffManager(key:SingletonEnforcer)
      {
         super();
         GlobalEngine.assert(key != null,"[FaceOffManager] :: Use instance()");
      }
      
      public static function getInstance() : FaceOffManager
      {
         if(m_instance == null)
         {
            m_instance = new FaceOffManager(new SingletonEnforcer());
         }
         return m_instance;
      }
      
      public static function getFeatureSpecificKey(key:String) : String
      {
         var result:String = key;
         if(Boolean(m_config) && Boolean(m_config["featureName"]) && ZLocUtils.hasString(FaceOffManager.DEFAULT_FEATURE_NAME,m_config["featureName"] + "_" + key))
         {
            result = m_config["featureName"] + "_" + key;
         }
         return result;
      }
      
      public static function getFeatureName() : String
      {
         var featureName:String = DEFAULT_FEATURE_NAME;
         if(Boolean(m_config) && Boolean(m_config["featureName"]))
         {
            featureName = m_config["featureName"];
         }
         return featureName;
      }
      
      public function displayDialog(trackBackoff:Boolean = false) : void
      {
         var roundDates:Array = null;
         Global.player.setFeatureLastShown(FaceOffManager.getFeatureName(),GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
         if(!this.m_openingWindow)
         {
            this.m_openingWindow = true;
            roundDates = this.m_dates[this.m_currentStage];
            if(!FarmGameUtil.isTimeWithinDateRange(roundDates[0],roundDates[1]))
            {
               ++this.m_currentStage;
               TransactionManager.addTransaction(new TGenericTransaction("FaceOffService","refreshFaceOffData",this.refreshCallback));
            }
            else
            {
               this.showWindow();
            }
         }
      }
      
      private function showWindow() : void
      {
         if(this.m_currentStage < this.m_numStages)
         {
            m_countWindow = new FaceOffWindow(this.m_windowAsset);
            UI.displayPopup(m_countWindow);
         }
         else
         {
            Global.hud.rightSideIconQueue.removeIconByName(getFeatureName());
         }
         this.m_openingWindow = false;
      }
      
      public function refreshCallback(result:Object) : void
      {
         if(result)
         {
            FeatureOptionsManager.getInstance().setFeature(FaceOffManager.DEFAULT_FEATURE_NAME,result);
            this.m_featureOptions = FeatureOptionsManager.getInstance().getFeatureOption(FaceOffManager.DEFAULT_FEATURE_NAME);
            this.showResultDialog(this.showWindow);
         }
      }
      
      public function setupFaceOff() : void
      {
         var hudIconData:Object = null;
         var iconName:String = null;
         var timeText:String = "";
         var hudIconIndex:int = 0;
         this.m_lastVoteTime = 0;
         this.dataParsing();
         if(this.m_faceOffName)
         {
            hudIconData = {
               "hudIconIndex":hudIconIndex,
               "iconTooltip":timeText
            };
            hudIconData.iconTooltip = ZLocUtils.t("Dialogs",FaceOffManager.getFeatureSpecificKey("FaceOff_hudIcon"));
            iconName = getFeatureName();
            m_hudIcon = Global.hud.rightSideIconQueue.addIcon(iconName,DynamicIconQueue.ADD_BY_PRIORITY,null,hudIconData,false) as FaceOffQueuedIcon;
            if(m_hudIcon)
            {
               m_hudIcon.toolTipWidth = HUDICON_TOOLTIP_WIDTH;
            }
         }
         var showResults:Boolean = this.showResultDialog();
         if(!this.canVote() && this.m_lastVoteTime != 0)
         {
            this.m_hudTimer = new Timer((this.m_lastVoteTime + this.m_voteInterval) * 1000 - GlobalEngine.serverTime);
            this.m_hudTimer.addEventListener(TimerEvent.TIMER,this.timerComplete);
            this.m_hudTimer.start();
         }
         else if(Boolean(m_hudIcon) && !showResults)
         {
            m_hudIcon.onAdd();
         }
      }
      
      private function showResultDialog(callback:Function = null) : Boolean
      {
         var faceOffFeatureOptions:Object = null;
         var round:int = 0;
         var roundObject:Object = null;
         var picked:String = null;
         var roundWinner:String = null;
         var window:FaceOffShareReward = null;
         var consolationWindow:FaceOffShareConsolation = null;
         var mapping:Object = null;
         var key:String = null;
         var pickedObject:Object = null;
         var item:Object = null;
         var competitorsObject:Object = null;
         var competitorNumber:int = 0;
         var competingObject:Object = null;
         var notPicked:String = null;
         var competitorName:String = null;
         var result:Boolean = false;
         var consolationItems:Object = new Object();
         if(this.m_featureOptions)
         {
            faceOffFeatureOptions = this.m_featureOptions[DEFAULT_FEATURE_NAME];
            if(faceOffFeatureOptions)
            {
               round = 1;
               roundObject = faceOffFeatureOptions[round];
               while(roundObject)
               {
                  picked = "";
                  roundWinner = "";
                  if(roundObject["vote"])
                  {
                     picked = roundObject["vote"];
                     if(roundObject["status"] != "finished")
                     {
                        break;
                     }
                     mapping = faceOffFeatureOptions["mapping"];
                     if(mapping)
                     {
                        for(key in mapping)
                        {
                           item = mapping[key];
                           if(item["consolation"] == true)
                           {
                              consolationItems[item["round"]] = key;
                           }
                        }
                        pickedObject = mapping[picked];
                        if(pickedObject)
                        {
                           competitorsObject = pickedObject["competitors"];
                           if(competitorsObject)
                           {
                              competitorNumber = 0;
                              competingObject = competitorsObject[competitorNumber];
                              while(competingObject)
                              {
                                 notPicked = "";
                                 competitorName = competingObject["@attributes"]["name"];
                                 if(competitorName != picked)
                                 {
                                    notPicked = competitorName;
                                    if(Number(roundObject[notPicked]) > Number(roundObject[picked]))
                                    {
                                       roundWinner = notPicked;
                                    }
                                    else
                                    {
                                       roundWinner = picked;
                                    }
                                 }
                                 competingObject = competitorsObject[++competitorNumber];
                              }
                           }
                        }
                     }
                  }
                  if(picked != null && picked != "" && !Global.player.getSeenFlag(this.m_faceOffName + "FaceOffRewardRound_" + round) && roundObject["status"] == "finished")
                  {
                     if(roundWinner == picked)
                     {
                        window = new FaceOffShareReward("assets/dialogs/FV_faceoff_reward.swf",picked,callback);
                        UI.displayPopup(window,false);
                        Global.player.addGift(picked);
                     }
                     else
                     {
                        Global.player.addGift(consolationItems[round]);
                        consolationWindow = new FaceOffShareConsolation("assets/dialogs/FV_faceoff_lose.swf",this.m_consolationPrizes[this.itemToStage(picked)],callback);
                        UI.displayPopup(consolationWindow,false);
                     }
                     if(m_hudIcon != null)
                     {
                        m_hudIcon.attachResultsArrow();
                     }
                     result = true;
                     Global.player.setSeenFlag(this.m_faceOffName + "FaceOffRewardRound_" + round);
                     break;
                  }
                  round++;
                  roundObject = this.m_featureOptions[DEFAULT_FEATURE_NAME][round];
               }
            }
         }
         return result;
      }
      
      public function getName() : String
      {
         return DEFAULT_FEATURE_NAME;
      }
      
      public function getStageItems(stage:int) : Array
      {
         if(Boolean(this.m_items) && Boolean(this.m_items[stage]))
         {
            return this.m_items[stage];
         }
         return null;
      }
      
      public function getFaceOffName() : String
      {
         return this.m_faceOffName;
      }
      
      public function itemToStage(item:String) : int
      {
         var j:int = 0;
         var result:int = 0;
         for(var i:int = 0; i < this.m_items.length; i++)
         {
            for(j = 0; j < this.m_items[i].length; j++)
            {
               if(this.m_items[i][j] == item)
               {
                  result = i;
               }
            }
         }
         return result;
      }
      
      public function getStagePicked(stage:int) : String
      {
         return this.m_picked[stage + 1];
      }
      
      public function getCurrentStage() : int
      {
         return this.m_currentStage;
      }
      
      public function getVotePercentage(item:String) : int
      {
         var itemName:String = null;
         var totalVotes:int = 0;
         var fraction:Number = 0;
         var result:int = 0;
         for each(itemName in this.getStageItems(this.itemToStage(item)))
         {
            totalVotes += this.m_numVotes[itemName];
         }
         if(this.m_numVotes.hasOwnProperty(item) && Boolean(totalVotes))
         {
            fraction = this.m_numVotes[item] / totalVotes;
            if(fraction < 0.5)
            {
               result = Math.floor(fraction * 100);
            }
            else if(fraction >= 0.5)
            {
               result = Math.ceil(fraction * 100);
            }
         }
         else if(this.m_numVotes[item])
         {
            result = 0;
         }
         return result;
      }
      
      public function vote(item:String) : void
      {
         var itemStage:int = this.itemToStage(item) + 1;
         TransactionManager.addTransaction(new TGenericTransaction(DEFAULT_TRANSACTION_SERVICE,"helpItem",this.voteTransactionComplete,[item]));
         this.m_numVotes[item] += 1;
         this.m_lastVoteTime = GlobalEngine.serverTime / 1000;
         this.m_hudTimer = new Timer(this.m_voteInterval * 1000);
         this.m_hudTimer.start();
         if(!this.m_hudTimer.hasEventListener(TimerEvent.TIMER))
         {
            this.m_hudTimer.addEventListener(TimerEvent.TIMER,this.timerComplete);
         }
         if(!this.m_picked[itemStage])
         {
            this.m_picked[itemStage] = item;
         }
      }
      
      public function getLastVoteTime() : Number
      {
         return this.m_lastVoteTime;
      }
      
      public function canVote() : Boolean
      {
         return this.m_lastVoteTime + this.m_voteInterval < GlobalEngine.serverTime / 1000;
      }
      
      public function getVoteInterval() : Number
      {
         return this.m_voteInterval;
      }
      
      public function getTimeRemaining() : String
      {
         var timeLeftSeconds:Number = (FarmGameUtil.synchronizedDateToNumber(this.m_dates[this.m_currentStage][1]) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return FarmGameUtil.toFriendlyTime(timeLeftSeconds);
      }
      
      public function getWinningItem(stage:int) : String
      {
         var item:String = null;
         var winner:String = "";
         var mostVotes:int = 0;
         for each(item in this.getStageItems(stage))
         {
            if(this.m_numVotes[item] > mostVotes)
            {
               winner = item;
               mostVotes = int(this.m_numVotes[item]);
            }
         }
         return winner;
      }
      
      public function getFacePiles(item:String) : Array
      {
         var result:Array = null;
         if(this.m_facePiles[item])
         {
            result = this.m_facePiles[item];
         }
         return result;
      }
      
      public function getConsolationPrize(stage:int) : String
      {
         return this.m_consolationPrizes[stage];
      }
      
      public function getNumberFriendVotes(stage:int) : int
      {
         var result:int = 0;
         if(this.m_numFriendVotes[stage])
         {
            result = int(this.m_numFriendVotes[stage]);
         }
         return result;
      }
      
      private function voteTransactionComplete(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData,ZCacheUtil.applyPartial(this.handleFeedPostReturn,this,[result]));
         }
      }
      
      private function handleFeedPostReturn(result:Object, success:Boolean) : void
      {
         if(result == null)
         {
            result = {};
         }
         result.postSuccessful = success;
         if(result["lastPosted"])
         {
            this.m_lastVoteTime = result["lastPosted"];
            Global.player.setFeatureLastShown(this.m_faceOffName,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         }
      }
      
      private function timerComplete(event:Event) : void
      {
         m_hudIcon.onAdd();
      }
      
      private function dataParsing() : void
      {
         var faceOff:XML = null;
         var validFaceOff:Boolean = false;
         var attributes:XML = null;
         var assetPath:Array = null;
         var rounds:Array = null;
         var round:XML = null;
         var items:Array = null;
         var itemList:XMLList = null;
         var item:Object = null;
         var roundDates:Array = null;
         var prereqs:Array = null;
         var prereq:Object = null;
         var itemNumVotes:Array = null;
         var facePilesAsNumbers:Array = null;
         var itemName:String = null;
         var facePiles:Array = null;
         var facePileArray:String = null;
         var stringName:String = null;
         this.m_items = new Array();
         this.m_featureLoadingTime = GlobalEngine.serverTime;
         this.m_numStages = 0;
         this.m_picked = new Array();
         this.m_dates = new Array();
         this.m_consolationPrizes = new Array();
         this.m_numVotes = new Object();
         this.m_facePiles = new Object();
         this.m_numFriendVotes = new Object();
         this.m_voteInterval = Global.flashHotParams["FACEOFF_FEED_THROTTLE"];
         var feedThrottleVariant:int = Global.experimentManager.getExperimentVariant("fv_face_off_time_throttle");
         switch(feedThrottleVariant)
         {
            case 0:
               this.m_voteInterval = Global.flashHotParams["FACEOFF_FEED_THROTTLE0"];
               break;
            case 1:
               this.m_voteInterval = Global.flashHotParams["FACEOFF_FEED_THROTTLE1"];
               break;
            case 2:
               this.m_voteInterval = Global.flashHotParams["FACEOFF_FEED_THROTTLE2"];
               break;
            case 3:
               this.m_voteInterval = Global.flashHotParams["FACEOFF_FEED_THROTTLE3"];
         }
         this.m_featureOptions = FeatureOptionsManager.getInstance().getFeatureOption(FaceOffManager.DEFAULT_FEATURE_NAME);
         if(this.m_featureOptions != null && Boolean(this.m_featureOptions[DEFAULT_FEATURE_NAME]))
         {
            if(this.m_featureOptions[DEFAULT_FEATURE_NAME]["faceOffFeed"])
            {
               this.m_lastVoteTime = this.m_featureOptions[DEFAULT_FEATURE_NAME]["faceOffFeed"];
            }
         }
         this.m_gameSettings = Global.farmGameSettingsManager.getFeatureXML(FaceOffManager.DEFAULT_FEATURE_NAME);
         var faceOffs:Array = Utilities.xmlListToArray(this.m_gameSettings.faceoff);
         var currFaceOff:int = -1;
         for(var count:int = 0; count < faceOffs.length; count++)
         {
            faceOff = faceOffs[count];
            validFaceOff = true;
            if(faceOff.hasOwnProperty("prereqs"))
            {
               validFaceOff = PrerequisiteUtility.arePrerequisitesMet(PrerequisiteUtility.parseXmlNodePrereqs(faceOff.child("prereqs").prereq));
            }
            if(validFaceOff)
            {
               currFaceOff = count;
               break;
            }
         }
         if(currFaceOff != -1 && Boolean(this.m_featureOptions))
         {
            this.m_faceOffName = faceOffs[currFaceOff].attribute("name");
            attributes = this.m_gameSettings.faceoff[0] as XML;
            assetPath = Utilities.xmlListToArray(attributes.swf);
            this.m_windowAsset = assetPath[0].attribute("url");
            rounds = Utilities.xmlListToArray(attributes.round);
            for each(round in rounds)
            {
               items = new Array();
               itemList = round.items.item;
               for each(item in itemList)
               {
                  items.push(item.attribute("name"));
               }
               this.m_consolationPrizes.push((round.consolation.attribute("name")[0] as XML).toString());
               roundDates = new Array(2);
               prereqs = Utilities.xmlListToArray(round.prereqs.prereq);
               for each(prereq in prereqs)
               {
                  if(prereq.attribute("type") == "start_time")
                  {
                     roundDates[0] = prereq.attribute("value")[0];
                  }
                  if(prereq.attribute("type") == "end_time")
                  {
                     roundDates[1] = prereq.attribute("value")[0];
                  }
               }
               if(this.m_featureOptions[DEFAULT_FEATURE_NAME])
               {
                  if(this.m_featureOptions[DEFAULT_FEATURE_NAME][round.attribute("number")])
                  {
                     if(this.m_featureOptions[DEFAULT_FEATURE_NAME][round.attribute("number")]["vote"])
                     {
                        this.m_picked[round.attribute("number")] = this.m_featureOptions[DEFAULT_FEATURE_NAME][round.attribute("number")]["vote"];
                     }
                     itemNumVotes = new Array();
                     facePilesAsNumbers = new Array();
                     if(this.m_featureOptions[DEFAULT_FEATURE_NAME][round.attribute("number")]["vote"])
                     {
                        this.m_picked[round.attribute("number")] = this.m_featureOptions[DEFAULT_FEATURE_NAME][round.attribute("number")]["vote"];
                     }
                     if(this.m_featureOptions[DEFAULT_FEATURE_NAME][round.attribute("number")]["helped"])
                     {
                        this.m_numFriendVotes[round.attribute("number") - 1] = this.m_featureOptions[DEFAULT_FEATURE_NAME][round.attribute("number")]["helped"];
                     }
                     for each(itemName in items)
                     {
                        facePiles = new Array();
                        if(this.m_featureOptions[DEFAULT_FEATURE_NAME][round.attribute("number")].hasOwnProperty(itemName))
                        {
                           this.m_numVotes[itemName] = Number(this.m_featureOptions[DEFAULT_FEATURE_NAME][round.attribute("number")][itemName]);
                        }
                        facePileArray = itemName + "FacePile";
                        if(this.m_featureOptions[DEFAULT_FEATURE_NAME][round.attribute("number")][facePileArray])
                        {
                           facePiles = this.m_featureOptions[DEFAULT_FEATURE_NAME][round.attribute("number")][facePileArray];
                           facePilesAsNumbers = new Array();
                           for each(stringName in facePiles)
                           {
                              facePilesAsNumbers.push(Number(stringName));
                           }
                           this.m_facePiles[itemName] = facePilesAsNumbers;
                        }
                     }
                  }
               }
               if(FarmGameUtil.isTimeWithinDateRange(roundDates[0],roundDates[1]))
               {
                  this.m_currentStage = round.attribute("number") - 1;
               }
               this.m_dates.push(roundDates);
               ++this.m_numStages;
               this.m_items.push(items);
            }
         }
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
