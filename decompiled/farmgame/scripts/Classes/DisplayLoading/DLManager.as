package Classes.DisplayLoading
{
   import Managers.PerformanceExperimentManager;
   import com.urbansquall.ginger.Animation;
   import flash.system.System;
   import flash.utils.Dictionary;
   
   public class DLManager
   {
      
      private static var m_animationMemoryLimit:int;
      
      private static var m_animationThreshold:int;
      
      public static const ANIMATION_PLAYER_THRESHOLD:int = 7;
      
      public static const ANIMATION_PLAYER_MEMORY_LIMIT:int = 400;
      
      public static const ANIMATION_PLAYER_THRESHOLD_V2:int = 5;
      
      public static const ANIMATION_PLAYER_MEMORY_LIMIT_V2:int = 200;
      
      protected static var m_loadOrder:Array = new Array();
      
      protected static var m_loadOrderSorted:Boolean = false;
      
      protected static var m_loadingAllowed:Boolean = false;
      
      private static var m_animations:Dictionary = new Dictionary(true);
      
      private static var m_totalAnimationMemory:int = 0;
      
      public function DLManager()
      {
         super();
      }
      
      public static function addDL(displayLoader:MapResourceDL) : void
      {
         if(m_loadingAllowed)
         {
            displayLoader.loadObjects();
         }
         else
         {
            m_loadOrder.push(displayLoader);
         }
      }
      
      public static function startLoading() : void
      {
         var displayLoader:MapResourceDL = null;
         var memory:Number = NaN;
         if(!m_loadOrderSorted)
         {
            m_loadOrder.sort(sortDLs);
            m_loadOrderSorted = true;
         }
         m_loadingAllowed = true;
         for(var ind:int = 0; ind < m_loadOrder.length; ind++)
         {
            displayLoader = m_loadOrder[ind] as MapResourceDL;
            if(displayLoader)
            {
               displayLoader.useAnimation = shouldUseAnimation(displayLoader);
               displayLoader.loadObjects();
            }
         }
         m_loadOrder = new Array();
      }
      
      protected static function sortDLs(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:Number = (obj1 as MapResourceDL).loadPriority;
         var score2:Number = (obj2 as MapResourceDL).loadPriority;
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         return result;
      }
      
      public static function shouldUseAnimation(displayLoader:MapResourceDL) : Boolean
      {
         if(PerformanceExperimentManager.isInAnimationMemoryExperiment)
         {
            if(!m_animationThreshold)
            {
               if(GlobalEngine.getFlashVar("animationThreshold"))
               {
                  m_animationThreshold = int(GlobalEngine.getFlashVar("animationThreshold"));
               }
               else if(PerformanceExperimentManager.isInOptimizedSwfQAExperiment)
               {
                  m_animationThreshold = 1;
               }
               else
               {
                  m_animationThreshold = ANIMATION_PLAYER_THRESHOLD_V2;
               }
            }
            return displayLoader.canUseAnimation && displayLoader.getInstanceCount() >= m_animationThreshold;
         }
         return displayLoader.canUseAnimation && displayLoader.getInstanceCount() >= ANIMATION_PLAYER_THRESHOLD;
      }
      
      public static function get hasLoadingBegun() : Boolean
      {
         return m_loadingAllowed;
      }
      
      public static function lockLoading() : void
      {
         m_loadingAllowed = false;
      }
      
      public static function isWithinMemoryLimit(limit:int) : Boolean
      {
         return Number(System.totalMemory / 1024 / 1024) < limit;
      }
      
      public static function getTotalAnimationMemory() : int
      {
         var key:Object = null;
         var animation:Animation = null;
         var memory:int = 0;
         for(key in m_animations)
         {
            animation = key as Animation;
            if(animation)
            {
               memory += animation.totalMemory;
            }
         }
         m_totalAnimationMemory = memory;
         return memory;
      }
      
      public static function shouldMakeAnimations() : Boolean
      {
         var result:Boolean = false;
         if(PerformanceExperimentManager.isInAnimationMemoryExperiment)
         {
            if(!m_animationMemoryLimit)
            {
               if(GlobalEngine.getFlashVar("animationMemoryLimit"))
               {
                  m_animationMemoryLimit = int(GlobalEngine.getFlashVar("animationMemoryLimit"));
               }
               else if(PerformanceExperimentManager.isInOptimizedSwfQAExperiment)
               {
                  m_animationMemoryLimit = 800;
               }
               else
               {
                  m_animationMemoryLimit = ANIMATION_PLAYER_MEMORY_LIMIT_V2;
               }
            }
            result = getTotalAnimationMemory() < m_animationMemoryLimit * 1024 * 1024;
         }
         else
         {
            result = isWithinMemoryLimit(ANIMATION_PLAYER_MEMORY_LIMIT);
         }
         return result;
      }
      
      public static function registerAnimation(animation:Animation) : void
      {
         if(PerformanceExperimentManager.isInAnimationMemoryExperiment)
         {
            m_animations[animation] = animation.name;
            m_totalAnimationMemory += animation.totalMemory;
         }
      }
      
      public static function cleanUp() : void
      {
         var anim:Object = null;
         if(PerformanceExperimentManager.isInAnimationMemoryExperiment)
         {
            for(anim in m_animations)
            {
               anim.dispose();
            }
            getTotalAnimationMemory();
         }
      }
   }
}

