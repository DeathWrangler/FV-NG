package Managers
{
   import Classes.Constants.DooberConstants;
   import Classes.Doobers.Doober;
   import Classes.Doobers.DooberChance;
   import Classes.Doobers.DooberReward;
   import Classes.Doobers.DooberRewardView;
   import Classes.Doobers.DooberRewardViewController;
   import Classes.FarmGameObject;
   import Classes.util.FarmGameUtil;
   import flash.utils.Dictionary;
   
   public class DoobersManager
   {
      
      private static var m_instance:DoobersManager;
      
      public static const INIT_SALT_KEY:String = "initSalt";
      
      private var m_isSaltInitialized:Boolean = false;
      
      private var m_salt:int;
      
      private var m_ftueKey:String = null;
      
      private var m_dooberActions:Dictionary;
      
      public function DoobersManager()
      {
         super();
         this.m_dooberActions = new Dictionary();
      }
      
      public static function getInstance() : DoobersManager
      {
         if(null == m_instance)
         {
            m_instance = new DoobersManager();
         }
         return m_instance;
      }
      
      public function executeDooberAction(actionName:String, actionObject:FarmGameObject) : Boolean
      {
         var dooberXml:XML = null;
         var doober:Doober = null;
         var winningChance:DooberChance = null;
         var result:Boolean = false;
         if(this.m_dooberActions[actionName])
         {
            dooberXml = this.m_dooberActions[actionName] as XML;
            if(dooberXml)
            {
               doober = new Doober(dooberXml,actionObject);
               if(doober.isAvailable())
               {
                  winningChance = this.rollForDoober(doober);
                  if(winningChance)
                  {
                     this.applyAndShowRewards(winningChance,actionObject);
                     result = true;
                  }
               }
            }
         }
         return result;
      }
      
      private function rollForDoober(doober:Doober) : DooberChance
      {
         var total:Number = NaN;
         var randomNumber:Number = NaN;
         var chanceIndex:int = 0;
         var chance:DooberChance = null;
         var serverTime:Number = NaN;
         var actionCount:int = 0;
         var result:DooberChance = null;
         var chances:Vector.<DooberChance> = doober.getChances();
         if(chances.length > 0)
         {
            total = 0;
            ++this.m_salt;
            randomNumber = FarmGameUtil.getPsuedoRandomNumber(this.m_salt.toString());
            randomNumber = Math.round(randomNumber * DooberConstants.ROLL_PRECISION_MULTIPLIER);
            for(chanceIndex = 0; chanceIndex < chances.length; chanceIndex++)
            {
               chance = chances[chanceIndex];
               if(chance.isAvailable())
               {
                  if(chance.isFtueAvailable())
                  {
                     if(chance.getFtueWeight() > 0)
                     {
                        total += Math.round(chance.getFtueWeight() * DooberConstants.ROLL_PRECISION_MULTIPLIER);
                        if(randomNumber <= total)
                        {
                           result = chance;
                        }
                     }
                     else
                     {
                        result = chance;
                     }
                     if(null != result)
                     {
                        this.m_ftueKey = chance.getFtueKey();
                        if(chance.getRewards().length > 0)
                        {
                           Global.player.setSeenFlag(this.m_ftueKey);
                           if(chance.getDailyLimit() > 0)
                           {
                              Global.player.setFeatureLastShown("DooberCollected_" + chance.getExperiment(),GlobalEngine.serverTime,false);
                              Global.player.incrementActionCount("DooberCollected_" + chance.getExperiment(),false);
                           }
                        }
                        break;
                     }
                  }
                  else
                  {
                     total += Math.round(chance.getWeight() * DooberConstants.ROLL_PRECISION_MULTIPLIER);
                     if(randomNumber <= total)
                     {
                        if(chance.getDailyLimit() <= 0)
                        {
                           result = chance;
                           break;
                        }
                        serverTime = Math.round(GlobalEngine.serverTime / 1000);
                        if(serverTime - Global.player.getFeatureLastShown("DooberCollected_" + chance.getExperiment()) >= FarmGameUtil.NUM_SECS_IN_DAY)
                        {
                           Global.player.setFeatureLastShown("DooberCollected_" + chance.getExperiment(),GlobalEngine.serverTime,false);
                           Global.player.resetActionCount("DooberCollected_" + chance.getExperiment());
                           Global.player.incrementActionCount("DooberCollected_" + chance.getExperiment(),false);
                           result = chance;
                           break;
                        }
                        actionCount = Global.player.getActionCount("DooberCollected_" + chance.getExperiment());
                        if(actionCount < chance.getDailyLimit())
                        {
                           Global.player.incrementActionCount("DooberCollected_" + chance.getExperiment(),false);
                           result = chance;
                           break;
                        }
                     }
                  }
               }
            }
         }
         return result;
      }
      
      private function applyAndShowRewards(winningChance:DooberChance, actionObject:FarmGameObject) : Boolean
      {
         var rewardViews:Vector.<DooberRewardView> = null;
         var rewardIndex:int = 0;
         var dooberRewardViewController:DooberRewardViewController = null;
         var result:Boolean = false;
         var rewards:Vector.<DooberReward> = winningChance.getRewards();
         if(rewards.length > 0)
         {
            rewardViews = new Vector.<DooberRewardView>();
            for(rewardIndex = 0; rewardIndex < rewards.length; rewardIndex++)
            {
               rewards[rewardIndex].applyReward();
               rewardViews.push(rewards[rewardIndex].getRewardView());
            }
            dooberRewardViewController = new DooberRewardViewController(rewardViews,actionObject.getPosition());
            dooberRewardViewController.loadRewardViews();
            result = true;
            if(null != this.m_ftueKey && "" != this.m_ftueKey)
            {
               dooberRewardViewController.setFtueKey(this.m_ftueKey);
               this.m_ftueKey = null;
            }
         }
         return result;
      }
      
      public function setInitSalt(initSalt:Number) : void
      {
         if(!this.m_isSaltInitialized)
         {
            this.m_isSaltInitialized = true;
            this.m_salt = initSalt;
         }
      }
      
      public function setConfigXml(configXml:XML) : void
      {
         var dooberXml:XML = null;
         for each(dooberXml in configXml.doober)
         {
            this.m_dooberActions[Doober.getDooberActionNameFromConfig(dooberXml)] = dooberXml;
         }
      }
   }
}

