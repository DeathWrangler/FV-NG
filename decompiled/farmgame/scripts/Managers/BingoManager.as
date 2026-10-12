package Managers
{
   import Classes.Constants.ArrowType;
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.QueuedIcons.QueuedIconWithArrow;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.Bingo.BingoWindow;
   import Widgets.Windows.ExpiredRewardWindow;
   import com.adobe.serialization.json.JSON;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class BingoManager extends EventDispatcher
   {
      
      public static const BINGO_FEATURE:String = "bingoFeature";
      
      public static const BINGO_STAT:String = "bingo";
      
      public static const BINGO_FEATURE_SEEN_FLAG:String = "bingoFeature_Tutorial";
      
      public static const BINGO_SERVICE:String = "BingoService";
      
      private static const BINGO_PRIZE_RECAPTURE:String = "assets/dialogs/FV_Bingo_questPurchase.swf";
      
      private static const BINGO_EXPIRED_WINDOW_PREFIX:String = "bingoExpiredWindow_";
      
      public static const BINGO_DEFAULT_COOLDOWN_HOURS:int = 6;
      
      public static const BINGO_DEFAULT_AUTOPOP_HOURS:int = 10;
      
      public static const BINGO_VIRAL_POST_FREQUENCY_FLAG:String = "bingoFeedPost";
      
      public static const BUY_RANDOM_NUMBER_EVENT_NAME:String = "onBuyRandomNumberFinish";
      
      public static const BINGO_DEFAULT_XP_POINTS:int = 10;
      
      public static const BINGO_DEFAULT_CADANCE_NAME:String = "bingo";
      
      public static const BINGO_DEFAULT_START_DATE:String = "05/13/2013";
      
      public static const BINGO_DEFAULT_END_DATE:String = "05/30/2013";
      
      public static const BINGO_DEFAULT_PREVIOUS_END_DATE:String = "05/30/2013";
      
      public static const BINGO_DEFAULT_TITLE:String = "FARM BINGO";
      
      public static const BINGO_DEFAULT_WINDOW_BACKGROUND:String = "assets/dialogs/FV_Support/FV_Bingo/Bingo_bg_default.png";
      
      public static const BINGO_DEFAULT_MOTD:String = "assets/dialogs/FV_motd_Bingo.swf";
      
      public static const BINGO_DEFAULT_PRIZES:String = "saddleshoetree,atthehop,sheep_thickglasses,cow_designersuit,pegacorn_poodleskirt";
      
      public static const BINGO_DEFAULT_CARD_NUMBERS:String = "14,8,2,5,11,25,17,30,26,19,44,42,37,39,57,53,48,60,58,63,74,72,66,61";
      
      public static const BINGO_DEFAULT_CARD_NUMBERS_NOT_SELECTED:String = "1,3,4,6,7,9,10,12,13,15,16,18,20,21,22,23,24,27,28,29,31,32,33,34,35,36,38,40,41,43,45,46,47,49,50,51,52,54,55,56,59,62,64,65,67,68,69,70,71,73,75";
      
      public static const BINGO_BUY_DEFAULT_RANDOM_PRICE:int = 2;
      
      public static const BINGO_BUY_SPECIFIC_PRICE:int = 5;
      
      private static const BINGO_CARD_LENGTH:int = 24;
      
      private static const BINGO_PRIZES_LENGTH:int = 5;
      
      private static const BINGO_NUMS_IN_COLUMN:int = 5;
      
      private static const BINGO_NUMS_IN_ROW:int = 5;
      
      private static const BINGO_NUMS_IN_DIAGONAL:int = 4;
      
      private static const BINGO_NUMS_IN_CORNER:int = 4;
      
      private static const INITIAL_BALL_COUNT:int = -1;
      
      private static var cadenceName:String = "";
      
      private static var startDate:String = "";
      
      private static var endDate:String = "";
      
      private static var previousEndDate:String = "";
      
      private static var title:String = "";
      
      private static var windowBackground:String = "";
      
      private static var prizes:Array = [];
      
      private static var motd:String = "";
      
      private static var cardNumbers:Array = new Array();
      
      private static var cardNumbersNotSelected:Array = new Array();
      
      private static var buyRandomPrice:int = -1;
      
      private static var buySpecificPrice:int = -1;
      
      private static var cooldownHours:int = -1;
      
      private static var autopopHours:int = -1;
      
      private static var m_instance:BingoManager = null;
      
      private var m_prizesClaimed:Array = new Array();
      
      private var m_bingoCard:Array = new Array();
      
      private var m_bingoCardLength:int = 0;
      
      private var m_buyEventListenerCounter:int = 0;
      
      private var m_ballCount:int = -1;
      
      private var m_wasCadenceNameDisparityFound:Boolean = false;
      
      private var m_wasRecaptureDialogShownThisSession:Boolean = false;
      
      public function BingoManager(key:SingletonEnforcer)
      {
         super();
         if(!key)
         {
            throw new Error("Invalid BingoManager Singleton class. Use BingoManager.instance");
         }
         this.setBingoConsts();
         this.setBingoCard();
         this.m_wasCadenceNameDisparityFound = this.getBingoUserCadenceName() != null && this.isBingoNew();
      }
      
      public static function getEndDate() : String
      {
         return BingoManager.endDate;
      }
      
      public static function getTitle() : String
      {
         return BingoManager.title;
      }
      
      public static function getWindowBackground() : String
      {
         return BingoManager.windowBackground;
      }
      
      public static function getCardNumbers() : Array
      {
         return BingoManager.cardNumbers;
      }
      
      public static function getBuyRandomPrice() : int
      {
         return BingoManager.buyRandomPrice;
      }
      
      public static function getBuySpecificPrice() : int
      {
         return BingoManager.buySpecificPrice;
      }
      
      public static function getRecapturePrizesSeenFlagName() : String
      {
         return BINGO_EXPIRED_WINDOW_PREFIX + BingoManager.getEndDate();
      }
      
      public static function getInstance() : BingoManager
      {
         if(m_instance == null)
         {
            m_instance = new BingoManager(new SingletonEnforcer());
         }
         return m_instance;
      }
      
      public function displayBingo() : void
      {
         if(this.isBingoNew())
         {
            this.resetGame();
         }
         if(!this.isExpired())
         {
            UI.displayPopup(new BingoWindow(),false);
         }
         else
         {
            this.recapturePrizes();
         }
      }
      
      private function setBingoConsts() : void
      {
         var bingoVars:Object = com.adobe.serialization.json.JSON.decode(Global.flashHotParams["BINGO"]) as Object;
         if(bingoVars)
         {
            if(bingoVars.hasOwnProperty("CADENCENAME"))
            {
               cadenceName = bingoVars.CADENCENAME;
            }
            else
            {
               cadenceName = BINGO_DEFAULT_CADANCE_NAME;
            }
            if(bingoVars.hasOwnProperty("START_DATE"))
            {
               startDate = bingoVars.START_DATE;
            }
            else
            {
               cadenceName = BINGO_DEFAULT_START_DATE;
            }
            if(bingoVars.hasOwnProperty("END_DATE"))
            {
               endDate = bingoVars.END_DATE;
            }
            else
            {
               cadenceName = BINGO_DEFAULT_END_DATE;
            }
            if(bingoVars.hasOwnProperty("PREVIOUS_END_DATE"))
            {
               previousEndDate = bingoVars.PREVIOUS_END_DATE;
            }
            else
            {
               previousEndDate = BINGO_DEFAULT_PREVIOUS_END_DATE;
            }
            if(bingoVars.hasOwnProperty("TITLE"))
            {
               title = bingoVars.TITLE;
            }
            else
            {
               title = BINGO_DEFAULT_TITLE;
            }
            if(bingoVars.hasOwnProperty("WINDOW_BACKGROUND"))
            {
               windowBackground = bingoVars.WINDOW_BACKGROUND;
            }
            else
            {
               windowBackground = BINGO_DEFAULT_WINDOW_BACKGROUND;
            }
            if(bingoVars.hasOwnProperty("MOTD"))
            {
               motd = bingoVars.MOTD;
            }
            else
            {
               motd = BINGO_DEFAULT_MOTD;
            }
            if(bingoVars.hasOwnProperty("BUY_RANDOM_PRICE") && !isNaN(bingoVars.BUY_RANDOM_PRICE))
            {
               buyRandomPrice = bingoVars.BUY_RANDOM_PRICE;
            }
            else
            {
               buyRandomPrice = BINGO_BUY_DEFAULT_RANDOM_PRICE;
            }
            if(bingoVars.hasOwnProperty("BUY_SPECIFIC_PRICE") && !isNaN(bingoVars.BUY_SPECIFIC_PRICE))
            {
               buySpecificPrice = bingoVars.BUY_SPECIFIC_PRICE;
            }
            else
            {
               buySpecificPrice = BINGO_BUY_SPECIFIC_PRICE;
            }
            if(bingoVars.hasOwnProperty("COOLDOWN_HOURS") && !isNaN(bingoVars.COOLDOWN_HOURS))
            {
               cooldownHours = bingoVars.COOLDOWN_HOURS;
            }
            else
            {
               cooldownHours = BINGO_DEFAULT_COOLDOWN_HOURS;
            }
            if(bingoVars.hasOwnProperty("AUTOPOP_HOURS") && !isNaN(bingoVars.AUTOPOP_HOURS))
            {
               autopopHours = bingoVars.AUTOPOP_HOURS;
            }
            else
            {
               autopopHours = BINGO_DEFAULT_AUTOPOP_HOURS;
            }
            if(bingoVars.hasOwnProperty("PRIZES"))
            {
               prizes = bingoVars.PRIZES.split(",");
            }
            else
            {
               prizes = BINGO_DEFAULT_PRIZES.split(",");
            }
            if(bingoVars.hasOwnProperty("CARD_NUMBERS"))
            {
               cardNumbers = bingoVars.CARD_NUMBERS.split(",");
            }
            else
            {
               cardNumbers = BINGO_DEFAULT_CARD_NUMBERS.split(",");
            }
            if(bingoVars.hasOwnProperty("CARD_NUMBERS_NOT_SELECTED"))
            {
               cardNumbersNotSelected = bingoVars.CARD_NUMBERS_NOT_SELECTED.split(",");
            }
            else
            {
               cardNumbersNotSelected = BINGO_DEFAULT_CARD_NUMBERS_NOT_SELECTED.split(",");
            }
         }
      }
      
      private function setBingoCard() : void
      {
         this.m_bingoCard = BingoManager.cardNumbers;
         if(this.m_bingoCard == null)
         {
            this.m_bingoCard = BingoManager.BINGO_DEFAULT_CARD_NUMBERS.split(",");
         }
         this.m_bingoCardLength = this.m_bingoCard.length;
      }
      
      public function getStatsCounter() : String
      {
         return BINGO_STAT + BingoManager.cadenceName;
      }
      
      private function recapturePrizes() : Boolean
      {
         var recapturedShown:Boolean = false;
         var expiredWindowSeenFlag:String = BingoManager.getRecapturePrizesSeenFlagName();
         var bingoExpired:Boolean = this.isExpired();
         if(this.m_wasCadenceNameDisparityFound && !this.m_wasRecaptureDialogShownThisSession || bingoExpired && !Global.player.getSeenFlag(expiredWindowSeenFlag))
         {
            if(bingoExpired)
            {
               Global.player.setSeenFlag(expiredWindowSeenFlag);
               Global.hud.rightSideIconQueue.removeIconByName(BingoManager.BINGO_FEATURE);
            }
            this.showRecaptureDialog();
            this.resetGame();
            this.m_wasRecaptureDialogShownThisSession = true;
            recapturedShown = true;
         }
         return recapturedShown;
      }
      
      private function showRecaptureDialog() : void
      {
         var statsCounter:String = null;
         var expiredRewardWindow:ExpiredRewardWindow = null;
         var itemsNotReceived:Array = this.getAllUnclaimedPrizes();
         if(itemsNotReceived.length > 0)
         {
            statsCounter = this.getStatsCounter() + "_recapture";
            expiredRewardWindow = new ExpiredRewardWindow(BINGO_PRIZE_RECAPTURE,"Bingo",itemsNotReceived,statsCounter);
            UI.displayPopup(expiredRewardWindow);
         }
      }
      
      public function getBallCount() : int
      {
         this.initializeBallCount();
         return this.m_ballCount;
      }
      
      private function initializeBallCount() : void
      {
         if(this.m_ballCount == INITIAL_BALL_COUNT || this.isBingoBuyNumberTransactionInProgress() == false)
         {
            this.m_ballCount = this.getRemainingBallCount();
         }
      }
      
      public function isBingoBuyNumberTransactionInProgress() : Boolean
      {
         return this.m_buyEventListenerCounter > 0;
      }
      
      public function resetGame() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(BingoManager.BINGO_SERVICE,"onInitializeGame"));
         this.initializeBingoNums();
         this.initializePrizeArray();
         this.m_buyEventListenerCounter = 0;
         this.m_ballCount = INITIAL_BALL_COUNT;
      }
      
      public function completeNow() : void
      {
         this.completeAllBingoNumsOnCard();
         this.completeAllPrizes();
         TransactionManager.addTransaction(new TGenericTransaction(BingoManager.BINGO_SERVICE,"onCompleteNow"));
      }
      
      private function setBingoNums(bingoNumArray:Array) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.BINGO,FeatureOptionsManager.BINGO_NUMS_ARRAY,bingoNumArray);
      }
      
      public function setBingoNumsFromCallback(bingoNums:Array) : void
      {
         if(bingoNums)
         {
            this.setBingoNums(bingoNums);
         }
      }
      
      public function getBingoNums() : Array
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.BINGO,FeatureOptionsManager.BINGO_NUMS_ARRAY) as Array;
      }
      
      private function setBingoCadenceName() : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.BINGO,FeatureOptionsManager.BINGO_CADENCE_NAME,BingoManager.cadenceName);
      }
      
      private function getBingoUserCadenceName() : String
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.BINGO,FeatureOptionsManager.BINGO_CADENCE_NAME) as String;
      }
      
      private function updateBingoNums(bingoNum:int, bingoIndex:int = -1, isClaimed:Boolean = false) : void
      {
         var i:int = 0;
         var numArray:Array = this.getBingoNums();
         var numArrayLength:int = int(numArray.length);
         var isUpdated:Boolean = false;
         if(numArray != null || numArray is Array)
         {
            for(i = 0; i < numArrayLength; i++)
            {
               if(numArray[i].bingoNum == bingoNum)
               {
                  numArray[i].isClaimed = isClaimed;
                  numArray[i].bingoIndex = bingoIndex;
                  isUpdated = true;
                  break;
               }
            }
            if(!isUpdated)
            {
               numArray.push({
                  "bingoNum":bingoNum,
                  "bingoIndex":bingoIndex,
                  "isClaimed":isClaimed
               });
            }
         }
         else
         {
            numArray = new Array();
            numArray.push({
               "bingoNum":bingoNum,
               "bingoIndex":bingoIndex,
               "isClaimed":isClaimed
            });
         }
         this.setBingoNums(numArray);
      }
      
      private function initializeBingoNums() : void
      {
         var numArray:Array = new Array();
         this.setBingoNums(numArray);
      }
      
      private function completeAllBingoNumsOnCard() : void
      {
         var completedArray:Array = new Array();
         if(this.m_bingoCard == null || this.m_bingoCardLength != BINGO_CARD_LENGTH)
         {
            this.setBingoCard();
         }
         for(var index:int = 0; index < this.m_bingoCardLength; index++)
         {
            completedArray.push({
               "bingoNum":this.m_bingoCard[index],
               "bingoIndex":index,
               "isClaimed":true
            });
         }
         this.setBingoNums(completedArray);
      }
      
      private function setBingoPrizesArray(bingoPrizesArray:Array) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.BINGO,FeatureOptionsManager.BINGO_PRIZES_ARRAY,bingoPrizesArray);
      }
      
      public function getBingoPrizesArray() : Array
      {
         var bingoPrizeArray:Array = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.BINGO,FeatureOptionsManager.BINGO_PRIZES_ARRAY) as Array;
         if(bingoPrizeArray == null)
         {
            bingoPrizeArray = this.initializePrizeArray();
         }
         return bingoPrizeArray;
      }
      
      private function updateBingoPrizesArray(prize:String, isClaimed:Boolean = false, isPosted:Boolean = false) : void
      {
         var i:int = 0;
         var prizeArray:Array = this.getBingoPrizesArray();
         var prizeArrayLength:int = int(prizeArray.length);
         if(prizeArray != null || prizeArray is Array)
         {
            for(i = 0; i < prizeArrayLength; i++)
            {
               if(prizeArray[i].prize == prize)
               {
                  prizeArray[i].isClaimed = isClaimed;
                  prizeArray[i].isPosted = isPosted;
                  break;
               }
            }
         }
         this.setBingoPrizesArray(prizeArray);
      }
      
      private function initializePrizeArray() : Array
      {
         var prize:FarmItem = null;
         var bingoPrizesNames:Array = BingoManager.prizes;
         var bingoPrizesNamesLength:int = int(bingoPrizesNames.length);
         if(bingoPrizesNames == null || bingoPrizesNamesLength != BINGO_PRIZES_LENGTH)
         {
            bingoPrizesNames = BINGO_DEFAULT_PRIZES.split(",");
         }
         var prizeName:String = null;
         var prizeArray:Array = new Array();
         for(var i:int = 0; i < bingoPrizesNamesLength; i++)
         {
            prizeName = bingoPrizesNames[i];
            prize = Global.farmGameSettingsManager.getFarmItemByName(prizeName);
            if(prize)
            {
               prizeArray.push({
                  "prize":prizeName,
                  "isClaimed":false,
                  "isPosted":false
               });
            }
         }
         this.setBingoPrizesArray(prizeArray);
         return prizeArray;
      }
      
      public function initializePrizeArrayIfNew() : void
      {
         if(this.isBingoNew())
         {
            TransactionManager.addTransaction(new TGenericTransaction(BingoManager.BINGO_SERVICE,"onInitializePrizeArrayIfNew"));
            this.initializePrizeArray();
            this.setBingoCadenceName();
         }
      }
      
      private function isBingoNew() : Boolean
      {
         var userCadenceName:String = this.getBingoUserCadenceName();
         var runtimeCadenceName:String = BingoManager.cadenceName;
         return userCadenceName == null || userCadenceName != runtimeCadenceName;
      }
      
      public function getAllUnclaimedPrizes() : Array
      {
         var prize:FarmItem = null;
         var unclaimedPrizes:Array = new Array();
         var currentPrizeArray:Array = this.getBingoPrizesArray();
         var currentPrizesLength:int = int(currentPrizeArray.length);
         for(var i:int = 0; i < currentPrizesLength; i++)
         {
            if(currentPrizeArray[i].isClaimed == false)
            {
               prize = Global.farmGameSettingsManager.getFarmItemByName(currentPrizeArray[i].prize);
               if(prize)
               {
                  unclaimedPrizes.push(prize);
               }
            }
         }
         return unclaimedPrizes;
      }
      
      public function completeAllPrizes() : void
      {
         var prizeArray:Array = this.getBingoPrizesArray();
         var prizeArrayLength:int = int(prizeArray.length);
         var isPosted:Boolean = false;
         for(var i:int = 0; i < prizeArrayLength; i++)
         {
            if(prizeArray[i].isClaimed == false)
            {
               Global.player.addGift(prizeArray[i].prize);
               prizeArray[i].isClaimed = true;
               if(i == prizeArrayLength - 1)
               {
                  isPosted = false;
               }
               else
               {
                  isPosted = true;
               }
               prizeArray[i].isPosted = isPosted;
            }
         }
         this.setBingoPrizesArray(prizeArray);
      }
      
      public function playBingoNum() : Array
      {
         var i:int = 0;
         var bingoNum:int = 0;
         var bingoIndex:int = 0;
         var isNumberOnCard:Boolean = false;
         var bingoNumPlayedData:Array = new Array();
         var bingoNumArray:Array = this.getBingoNums();
         var bingoNumArrayLength:int = int(bingoNumArray.length);
         if(bingoNumArray != null)
         {
            for(i = 0; i < bingoNumArrayLength; i++)
            {
               if(bingoNumArray[i].isClaimed == false)
               {
                  TransactionManager.addTransaction(new TGenericTransaction(BingoManager.BINGO_SERVICE,"onPlayNumber"));
                  bingoNum = int(bingoNumArray[i].bingoNum);
                  bingoIndex = int(bingoNumArray[i].bingoIndex);
                  isNumberOnCard = this.isNumberOnBingoCard(bingoNum);
                  this.updateBingoNums(bingoNum,bingoIndex,true);
                  bingoNumPlayedData.push({
                     "bingoNum":bingoNum,
                     "bingoIndex":bingoIndex,
                     "isNumberOnCard":isNumberOnCard
                  });
                  break;
               }
            }
         }
         return bingoNumPlayedData;
      }
      
      public function buySpecificNum(indexSelected:int) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(BingoManager.BINGO_SERVICE,"onBuySpecificNumber",null,[indexSelected]));
         var valueOfIndex:int = int(this.m_bingoCard[indexSelected]);
         this.updateBingoNums(valueOfIndex,indexSelected,true);
      }
      
      public function buyRandomNum() : void
      {
         ++this.m_buyEventListenerCounter;
         ++this.m_ballCount;
         TransactionManager.addTransaction(new TGenericTransaction(BingoManager.BINGO_SERVICE,"onBuyRandomNumber",this.onFinishBuyRandomNumber));
      }
      
      private function onFinishBuyRandomNumber(result:Object) : void
      {
         var randomIndexInArray:int = 0;
         var bingoNumber:int = 0;
         if(Boolean(result) && Boolean(result.bingoIndex))
         {
            randomIndexInArray = int(result.bingoIndex);
            bingoNumber = int(this.m_bingoCard[randomIndexInArray]);
            this.updateBingoNums(bingoNumber,randomIndexInArray);
            --this.m_buyEventListenerCounter;
            dispatchEvent(new Event(BUY_RANDOM_NUMBER_EVENT_NAME));
         }
      }
      
      public function getRemainingBallCount() : int
      {
         var i:int = 0;
         var ballCount:int = 0;
         var bingoNumsArray:Array = this.getBingoNums();
         var bingoNumsArrayLength:int = int(bingoNumsArray.length);
         if(bingoNumsArray != null)
         {
            for(i = 0; i < bingoNumsArrayLength; i++)
            {
               if(bingoNumsArray[i].isClaimed == false)
               {
                  ballCount++;
               }
            }
         }
         return ballCount;
      }
      
      public function claimWinningPrizes() : Array
      {
         var i:int = 0;
         this.m_prizesClaimed = new Array();
         TransactionManager.addTransaction(new TGenericTransaction(BingoManager.BINGO_SERVICE,"winningPrizes"));
         var userBingoNums:Array = this.getBingoNums();
         var userBingoNumsLength:int = int(userBingoNums.length);
         var userPrizes:Array = this.getBingoPrizesArray();
         var userCurrentIndexs:Array = new Array();
         if(userBingoNums != null)
         {
            for(i = 0; i < userBingoNumsLength; i++)
            {
               if(userBingoNums[i]["isClaimed"] == true)
               {
                  userCurrentIndexs.push(userBingoNums[i]["bingoIndex"]);
               }
            }
            if(userPrizes[0].isClaimed == false && this.isColumnWon(userCurrentIndexs))
            {
               this.claimPrize(userPrizes[0].prize);
            }
            if(userPrizes[1].isClaimed == false && this.isRowWon(userCurrentIndexs))
            {
               this.claimPrize(userPrizes[1].prize);
            }
            if(userPrizes[2].isClaimed == false && this.isDiagonalWon(userCurrentIndexs))
            {
               this.claimPrize(userPrizes[2].prize);
            }
            if(userPrizes[3].isClaimed == false && this.isCornerWon(userCurrentIndexs))
            {
               this.claimPrize(userPrizes[3].prize);
            }
            if(userPrizes[4].isClaimed == false && this.isBoardComplete())
            {
               this.claimPrize(userPrizes[4].prize,true);
            }
         }
         return this.m_prizesClaimed;
      }
      
      private function claimPrize(prizeName:String, isFinal:Boolean = false) : void
      {
         this.updateBingoPrizesArray(prizeName,true);
         var prizeItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(prizeName);
         Global.player.addGift(prizeName);
         this.m_prizesClaimed.push({
            "prizeItem":prizeItem,
            "isFinal":isFinal
         });
      }
      
      private function isColumnWon(indexArray:Array) : Boolean
      {
         var isWinner:Boolean = false;
         var columnB:int = 0;
         var columnI:int = 0;
         var columnN:int = 0;
         var columnG:int = 0;
         var columnO:int = 0;
         var currentIndex:int = 0;
         var indexArrayLength:int = int(indexArray.length);
         for(var i:int = 0; i < indexArrayLength; i++)
         {
            currentIndex = int(indexArray[i]);
            if(currentIndex >= 0 && currentIndex <= 4)
            {
               columnB++;
            }
            else if(currentIndex >= 5 && currentIndex <= 9)
            {
               columnI++;
            }
            else if(currentIndex >= 10 && currentIndex <= 13)
            {
               columnN++;
            }
            else if(currentIndex >= 14 && currentIndex <= 18)
            {
               columnG++;
            }
            else if(currentIndex >= 19 && currentIndex <= 23)
            {
               columnO++;
            }
         }
         if(columnB == BINGO_NUMS_IN_COLUMN || columnI == BINGO_NUMS_IN_COLUMN || columnN == BINGO_NUMS_IN_COLUMN - 1 || columnG == BINGO_NUMS_IN_COLUMN || columnO == BINGO_NUMS_IN_COLUMN)
         {
            isWinner = true;
         }
         return isWinner;
      }
      
      private function isRowWon(indexArray:Array) : Boolean
      {
         var isWinner:Boolean = false;
         var row1:int = 0;
         var row2:int = 0;
         var row3:int = 0;
         var row4:int = 0;
         var row5:int = 0;
         var currentIndex:int = 0;
         var indexArrayLength:int = int(indexArray.length);
         for(var i:int = 0; i < indexArrayLength; i++)
         {
            currentIndex = int(indexArray[i]);
            if(currentIndex == 0 || currentIndex == 5 || currentIndex == 10 || currentIndex == 14 || currentIndex == 19)
            {
               row1++;
            }
            else if(currentIndex == 1 || currentIndex == 6 || currentIndex == 11 || currentIndex == 15 || currentIndex == 20)
            {
               row2++;
            }
            else if(currentIndex == 2 || currentIndex == 7 || currentIndex == 16 || currentIndex == 21)
            {
               row3++;
            }
            else if(currentIndex == 3 || currentIndex == 8 || currentIndex == 12 || currentIndex == 17 || currentIndex == 22)
            {
               row4++;
            }
            else if(currentIndex == 4 || currentIndex == 9 || currentIndex == 13 || currentIndex == 18 || currentIndex == 23)
            {
               row5++;
            }
         }
         if(row1 == BINGO_NUMS_IN_ROW || row2 == BINGO_NUMS_IN_ROW || row3 == BINGO_NUMS_IN_ROW - 1 || row4 == BINGO_NUMS_IN_ROW || row5 == BINGO_NUMS_IN_ROW)
         {
            isWinner = true;
         }
         return isWinner;
      }
      
      private function isDiagonalWon(indexArray:Array) : Boolean
      {
         var isWinner:Boolean = false;
         var diagonal1:int = 0;
         var diagonal2:int = 0;
         var currentIndex:int = 0;
         var indexArrayLength:int = int(indexArray.length);
         for(var i:int = 0; i < indexArrayLength; i++)
         {
            currentIndex = int(indexArray[i]);
            if(currentIndex == 0 || currentIndex == 6 || currentIndex == 17 || currentIndex == 23)
            {
               diagonal1++;
            }
            else if(currentIndex == 4 || currentIndex == 8 || currentIndex == 15 || currentIndex == 19)
            {
               diagonal2++;
            }
            if(diagonal1 == BINGO_NUMS_IN_DIAGONAL || diagonal2 == BINGO_NUMS_IN_DIAGONAL)
            {
               isWinner = true;
            }
         }
         return isWinner;
      }
      
      private function isCornerWon(indexArray:Array) : Boolean
      {
         var i:int = 0;
         var isWinner:Boolean = false;
         var corner:int = 0;
         var currentIndex:int = 0;
         for(var indexArrayLength:int = int(indexArray.length); i < indexArrayLength; )
         {
            currentIndex = int(indexArray[i]);
            if(currentIndex == 0 || currentIndex == 4 || currentIndex == 19 || currentIndex == 23)
            {
               corner++;
            }
            i++;
         }
         if(corner == BINGO_NUMS_IN_CORNER)
         {
            isWinner = true;
         }
         return isWinner;
      }
      
      public function isBoardComplete() : Boolean
      {
         var result:Boolean = false;
         if(this.getNumberOfSuccessfulBallsOnCard() == BINGO_CARD_LENGTH)
         {
            result = true;
         }
         return result;
      }
      
      public function canUserFinishGame() : Boolean
      {
         var result:Boolean = false;
         var successBingoCount:int = 0;
         var userBingoNums:Array = this.getBingoNums();
         var userBingoNumsLength:int = int(userBingoNums.length);
         for(var i:int = 0; i < userBingoNumsLength; i++)
         {
            if(this.isNumberOnBingoCard(userBingoNums[i].bingoNum) == true)
            {
               successBingoCount++;
            }
         }
         if(successBingoCount == this.m_bingoCardLength)
         {
            result = true;
         }
         return result;
      }
      
      public function isUserOverBingoCardLengthWithNextBall() : Boolean
      {
         var bingoNumsCount:int = this.getNumberOfSuccessfulBallsOnCard() + this.m_ballCount + 1;
         return bingoNumsCount > this.m_bingoCardLength;
      }
      
      public function isNumberOnBingoCard(bingoValue:int) : Boolean
      {
         var isOnBingoCard:Boolean = false;
         for(var i:int = 0; i < this.m_bingoCardLength; i++)
         {
            if(this.m_bingoCard[i] == bingoValue)
            {
               isOnBingoCard = true;
               break;
            }
         }
         return isOnBingoCard;
      }
      
      public function isExpired() : Boolean
      {
         var isExpired:Boolean = false;
         var currentTimeSeconds:int = Math.floor(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
         var startDateString:String = BingoManager.startDate;
         var startTimeSecond:int = 0;
         if(startDateString != "")
         {
            startTimeSecond = Math.floor(FarmGameUtil.synchronizedDateTimeToNumber(startDateString) / FarmGameUtil.NUM_MSECS_IN_SECOND);
         }
         if(this.getSecondsUntilExpiry() <= 0 || currentTimeSeconds < startTimeSecond)
         {
            isExpired = true;
         }
         return isExpired;
      }
      
      private function getSecondsUntilExpiry() : int
      {
         var currentTimeSeconds:int = Math.floor(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
         var endDateString:String = BingoManager.endDate;
         var expiryTimeSecond:int = 0;
         if(endDateString != "")
         {
            expiryTimeSecond = Math.floor(FarmGameUtil.synchronizedDateTimeToNumber(endDateString) / FarmGameUtil.NUM_MSECS_IN_SECOND);
         }
         return expiryTimeSecond - currentTimeSeconds;
      }
      
      public function canPost() : Boolean
      {
         var result:Boolean = false;
         var coolDownHours:int = BingoManager.cooldownHours != -1 ? BingoManager.cooldownHours : BINGO_DEFAULT_COOLDOWN_HOURS;
         var currentTime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_HOUR;
         var lastViralSent:int = Global.player.getFeatureLastShown(BINGO_VIRAL_POST_FREQUENCY_FLAG) / FarmGameUtil.NUM_SECS_IN_HOUR;
         var timeSinceLastPosted:int = Math.floor(currentTime - lastViralSent);
         if(lastViralSent == 0 || timeSinceLastPosted >= coolDownHours && timeSinceLastPosted > 0)
         {
            result = true;
         }
         return result;
      }
      
      public function getSecondsUntilPosting() : int
      {
         var timeUntilPostSecs:int = 0;
         var coolDownHours:int = BingoManager.cooldownHours != -1 ? BingoManager.cooldownHours : BINGO_DEFAULT_COOLDOWN_HOURS;
         var currentTime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var lastViralSent:int = Global.player.getFeatureLastShown(BINGO_VIRAL_POST_FREQUENCY_FLAG);
         var timeSinceLastPosted:int = Math.floor(currentTime - lastViralSent);
         return int(timeSinceLastPosted - coolDownHours);
      }
      
      public function shouldAutoPop() : Boolean
      {
         var result:Boolean = false;
         var autoPopHours:int = BingoManager.autopopHours != -1 ? BingoManager.autopopHours : BINGO_DEFAULT_AUTOPOP_HOURS;
         var featureLastShownHours:int = Global.player.getFeatureLastShown(BINGO_FEATURE) / FarmGameUtil.NUM_SECS_IN_HOUR;
         var currentTimeHours:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_HOUR;
         var timeSinceLastShown:int = Math.floor(currentTimeHours - featureLastShownHours);
         if(!this.isExpired() && this.canPost() && timeSinceLastShown >= autoPopHours && Global.player.canShowFeatureWithBackoff(BINGO_FEATURE) && featureLastShownHours < currentTimeHours && !Global.worldManager.isVisiting())
         {
            result = true;
         }
         return result;
      }
      
      public function getNumberOfSuccessfulBallsOnCard() : int
      {
         var j:int = 0;
         var numOfSuccess:int = 0;
         var numUsed:Array = this.getBingoNums();
         var numUsedLength:int = int(numUsed.length);
         if(this.m_bingoCard == null || this.m_bingoCardLength != BINGO_CARD_LENGTH)
         {
            this.setBingoCard();
         }
         for(var i:int = 0; i < numUsedLength; i++)
         {
            if(numUsed[i].isClaimed == true)
            {
               for(j = 0; j < this.m_bingoCardLength; j++)
               {
                  if(numUsed[i].bingoNum == this.m_bingoCard[j])
                  {
                     numOfSuccess++;
                     break;
                  }
               }
            }
         }
         return numOfSuccess;
      }
      
      private function shouldShowHUDIcon() : Boolean
      {
         var itemsNotReceived:Array = null;
         var showHUDIcon:Boolean = false;
         var expiredWindowSeenFlag:String = BingoManager.getRecapturePrizesSeenFlagName();
         var currentSurfacingVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BINGO_SURFACING);
         var isBingoExpired:Boolean = this.isExpired();
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_BINGO) >= Experiments.VARIANT_BINGO_FEATURE_ON_10 && (currentSurfacingVariant == Experiments.VARIANT_BINGO_SURFACING_HUD_AUTOPOP || currentSurfacingVariant == Experiments.VARIANT_BINGO_SURFACING_HUD) && (!isBingoExpired || isBingoExpired && !Global.player.getSeenFlag(expiredWindowSeenFlag)))
         {
            itemsNotReceived = this.getAllUnclaimedPrizes();
            if(itemsNotReceived.length > 0 || this.isBingoNew())
            {
               showHUDIcon = true;
            }
         }
         return showHUDIcon;
      }
      
      public function addHUDIcon() : void
      {
         var hoursUntilExpiryToDisplayArrow:int = 0;
         var hoursUntilExpiry:int = 0;
         var bingoIcon:QueuedIconWithArrow = null;
         if(this.shouldShowHUDIcon())
         {
            hoursUntilExpiryToDisplayArrow = int(FarmGameUtil.NUM_HOURS_IN_DAY);
            hoursUntilExpiry = this.getSecondsUntilExpiry() / FarmGameUtil.NUM_SECS_IN_HOUR;
            bingoIcon = Global.hud.rightSideIconQueue.addIcon(BingoManager.BINGO_FEATURE,DynamicIconQueue.ADD_BY_PRIORITY,null,false) as QueuedIconWithArrow;
            if(this.isBingoNew())
            {
               bingoIcon.attachArrow(ArrowType.ARROWNEW);
               bingoIcon.setArrowText(ZLocUtils.t("Dialogs","Bingo_HUD_New_Card"));
            }
            else if(hoursUntilExpiry <= hoursUntilExpiryToDisplayArrow && hoursUntilExpiry >= 0)
            {
               bingoIcon.attachArrow(ArrowType.ARROWEXPIRY);
               bingoIcon.setArrowText(ZLocUtils.t("Dialogs","Bingo_HUD_Expires",{"hours":hoursUntilExpiry}));
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
