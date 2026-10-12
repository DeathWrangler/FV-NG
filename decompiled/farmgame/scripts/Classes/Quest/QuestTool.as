package Classes.Quest
{
   import Classes.util.ExternalUtil;
   
   public class QuestTool
   {
      
      private static const JS_PROGRESS_LOC:String = "FarmNS.setOutputQuestProgress";
      
      private static const JS_REWARD_LOC:String = "FarmNS.setOutputQuestReward";
      
      private static const JS_INJECT_LOC:String = "FarmNS.setInjectProps";
      
      public function QuestTool()
      {
         super();
      }
      
      public static function init() : void
      {
         registerCallbacks();
      }
      
      public static function registerCallbacks() : void
      {
         var callId:String = ExternalUtil.instance.registerCallback(outputQuestProgress);
         ExternalUtil.instance.call(JS_PROGRESS_LOC,callId);
         var callId2:String = ExternalUtil.instance.registerCallback(outputQuestReward);
         ExternalUtil.instance.call(JS_REWARD_LOC,callId2);
         var callId3:String = ExternalUtil.instance.registerCallback(injectProps);
         ExternalUtil.instance.call(JS_INJECT_LOC,callId3);
      }
      
      public static function outputQuestReward(testXML:String) : void
      {
         var questXML:XML = stringToXML(testXML);
         var testQuest:FarmQuest = new FarmQuest(questXML);
         testQuest.showReward();
      }
      
      public static function outputQuestProgress(testXML:String) : void
      {
         var questXML:XML = stringToXML(testXML);
         var testQuest:FarmQuest = new FarmQuest(questXML);
         var bubbleCheck:String = questXML.frontend.rewardView;
         if(bubbleCheck.indexOf("Bubble") == -1)
         {
            testQuest.showProgress();
         }
      }
      
      public static function stringToXML(input:String) : XML
      {
         var holder:String = input.replace(/[^(\x00-\x7E)]*/g,"");
         var questXML:XML = new XML(holder);
         questXML.ignoreWhiteSpace = true;
         return questXML;
      }
      
      public static function injectProps(propString:String) : void
      {
         var split:Array = null;
         var count:int = 0;
         var arr:Array = propString.split(/\n/);
         var temp:String = "";
         for(count = 0; count < arr.length; count++)
         {
            temp = arr[count];
            split = temp.split(/=/);
            if(split.length == 2)
            {
               ZLoc.instance.injectString("Quests",split[0],split[1]);
            }
         }
      }
   }
}

