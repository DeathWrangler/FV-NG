package Classes.FeatureComponents
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import flash.external.ExternalInterface;
   
   public class IngameSurveyManager
   {
      
      private static var s_initialized:Boolean;
      
      private static const IGS_PREFIX:String = "ingameSurvey_";
      
      private static var s_instances:Object = {};
      
      private var m_question_dialogues:Array;
      
      private var m_question_dialogueKey:Array;
      
      private var m_question_types:Array;
      
      private var m_answers:Array;
      
      private var m_featureName:String;
      
      private var m_answeredFlag:Boolean;
      
      private var m_initialized:Boolean = true;
      
      private var m_context:String;
      
      private var m_callback:Function;
      
      public function IngameSurveyManager(multitonEnforcer:MultitonEnforcer, featureName:String)
      {
         var list:XMLList = null;
         var length:int = 0;
         var i:int = 0;
         var question:XML = null;
         var message:String = null;
         this.m_question_dialogues = [];
         this.m_question_dialogueKey = [];
         this.m_question_types = [];
         this.m_answers = [];
         super();
         if(multitonEnforcer == null)
         {
            throw new Error("IngameSurveyManager: use IngameSurveyManager.instanceForFeature()");
         }
         this.m_featureName = featureName;
         var ingameSurveyXML:XML = Global.farmGameSettingsManager.getFeatureXMLWithType(this.m_featureName,"ingameSurvey");
         if(ingameSurveyXML)
         {
            list = ingameSurveyXML.questions.question;
            length = list.length();
            for(i = 0; i < length; i++)
            {
               question = list[i];
               if(!question.hasOwnProperty("@type"))
               {
                  this.m_question_types[i] = "radio";
               }
               else
               {
                  this.m_question_types[i] = question.@type;
               }
               if(!question.hasOwnProperty("@dialogueKey"))
               {
                  this.m_initialized = false;
                  break;
               }
               this.m_question_dialogueKey[i] = question.@dialogueKey;
               message = ZLocUtils.t("Dialogs",this.m_question_dialogueKey[i]);
               this.m_question_dialogues[i] = message;
            }
            this.m_context = IGS_PREFIX + this.m_featureName;
            this.m_answeredFlag = Global.player.getSeenFlag(this.m_context);
         }
         else
         {
            this.m_initialized = false;
         }
      }
      
      public static function instanceForFeature(featureName:String) : IngameSurveyManager
      {
         var context:String = null;
         if(!s_initialized)
         {
            ExternalInterface.addCallback("submitAnswers",IngameSurveyManager.submitAnswers);
            s_initialized = true;
         }
         var manager:IngameSurveyManager = null;
         if(featureName != null && featureName != "")
         {
            context = IGS_PREFIX + featureName;
            if(!s_instances.hasOwnProperty(context))
            {
               manager = new IngameSurveyManager(new MultitonEnforcer(),featureName);
               if(manager.initialized)
               {
                  s_instances[context] = manager;
               }
               else
               {
                  manager = null;
               }
            }
            else
            {
               manager = s_instances[context];
            }
         }
         return manager;
      }
      
      public static function submitAnswers(answers:Array, context:String) : void
      {
         var i:int = 0;
         var manager:IngameSurveyManager = null;
         if(s_instances.hasOwnProperty(context))
         {
            manager = s_instances[context];
            for(i = 0; i < answers.length; i++)
            {
               manager.setAnswerString(answers[i],i);
            }
            if(manager.submit())
            {
               Global.player.setSeenFlag(manager.context);
               manager.m_answeredFlag = true;
               if(manager.callback != null)
               {
                  manager.callback();
               }
            }
         }
      }
      
      public function validate() : Boolean
      {
         var valid:Boolean = false;
         var length:int = int(this.m_question_dialogueKey.length);
         valid = length == this.m_answers.length;
         for(var i:int = 0; i < length; i++)
         {
            if(this.m_answers[i] == null || this.m_answers[i] == "")
            {
               valid = false;
               break;
            }
         }
         return valid;
      }
      
      public function submit() : Boolean
      {
         var i:int = 0;
         if(this.validate() && this.m_answeredFlag == false)
         {
            for(i = 0; i < this.numQuestions; i++)
            {
               FarmStatsManager.count("ingame_survey",this.m_featureName,this.m_question_dialogueKey[i],this.m_answers[i],Global.player.uid);
            }
            return true;
         }
         return false;
      }
      
      public function display() : void
      {
         ExternalInterface.call("ingameSurveyHandler.setupIngameSurvey",this.m_question_dialogues,this.m_context);
      }
      
      public function get answeredFlag() : Boolean
      {
         return this.m_answeredFlag;
      }
      
      public function get numQuestions() : int
      {
         return this.m_question_dialogueKey.length;
      }
      
      public function get questionDialogues() : Array
      {
         return this.m_question_dialogues;
      }
      
      public function get questionTypes() : Array
      {
         return this.m_question_types;
      }
      
      public function get initialized() : Boolean
      {
         return this.m_initialized;
      }
      
      public function setAnswerString(answer:String, questionIndex:int) : void
      {
         if(questionIndex >= 0 && questionIndex < this.m_question_dialogueKey.length && answer != null && answer != "")
         {
            this.m_answers[questionIndex] = answer;
         }
      }
      
      public function setAnswerInt(answer:int, questionIndex:int) : void
      {
         this.setAnswerString(answer.toString(),questionIndex);
      }
      
      public function set callback(closure:Function) : void
      {
         this.m_callback = closure;
      }
      
      public function get callback() : Function
      {
         return this.m_callback;
      }
      
      public function get context() : String
      {
         return this.m_context;
      }
   }
}

class MultitonEnforcer
{
   
   public function MultitonEnforcer()
   {
      super();
   }
}
