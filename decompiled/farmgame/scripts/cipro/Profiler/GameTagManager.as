package cipro.Profiler
{
   import flash.utils.Dictionary;
   
   public class GameTagManager
   {
      
      private static var s_samplerSets:Vector.<GameSamplerSet>;
      
      public static const TYPE_INTEGER:int = 0;
      
      public static const TYPE_NUMBER:int = 1;
      
      public static const TYPE_COUNT_NUMBER:int = 2;
      
      public static const TYPE_COUNT_INT:int = 3;
      
      public static const TYPE_STRING:int = 4;
      
      public static const UNIT_VALUE:int = 0;
      
      public static const UNIT_SECONDS:int = 1;
      
      public static const UNIT_MILLISECONDS:int = 2;
      
      public static const UNIT_MICROSECONDS:int = 3;
      
      public static const UNIT_MB:int = 4;
      
      public static const UNIT_KB:int = 5;
      
      public static const UPDATE_ASSIGN:int = 0;
      
      public static const UPDATE_POLLING:int = 1;
      
      private static var s_modeManager:ModeManager = null;
      
      private static var s_gameModes:Vector.<String> = new Vector.<String>();
      
      private static var s_gameModeMap:Dictionary = new Dictionary();
      
      private static var s_tagNames:Dictionary = new Dictionary();
      
      private static var s_samplerSetsNames:Dictionary = new Dictionary();
      
      private static var s_addTagCallbacks:Vector.<Function> = new Vector.<Function>();
      
      private static var s_addModeCallbacks:Vector.<Function> = new Vector.<Function>();
      
      private static var s_gameModeSamplerSet:int = -1;
      
      private static var s_gameModeTag:GameTagObject = null;
      
      public function GameTagManager()
      {
         super();
      }
      
      public static function initialize(param1:ModeManager) : void
      {
         s_modeManager = param1;
         s_samplerSets = new Vector.<GameSamplerSet>();
         s_gameModeSamplerSet = registerSamplerSet("GameMode");
         s_gameModeTag = registerGameTag("GameMode",CurrentGameModeString,TYPE_STRING);
      }
      
      public static function addGameMode(param1:String) : int
      {
         var _loc3_:Function = null;
         var _loc2_:int = int(s_gameModes.length);
         s_gameModes.push(param1);
         for each(_loc3_ in s_addModeCallbacks)
         {
            _loc3_(param1);
         }
         return _loc2_;
      }
      
      public static function registerAddModeCallback(param1:Function) : void
      {
         s_addModeCallbacks.push(param1);
      }
      
      public static function registerGameTag(param1:String, param2:Function, param3:int, param4:int = 1) : GameTagObject
      {
         var _loc5_:GameTagObject = null;
         var _loc6_:Function = null;
         if(s_tagNames[param1])
         {
            throw Error("GameTag already defined with name: " + param1);
         }
         if(param4 == UPDATE_POLLING)
         {
            _loc5_ = new GameTagObject(param1,param2,param3,UPDATE_POLLING);
         }
         else
         {
            _loc5_ = new GameTagAssignObject(param1,param2,param3,UPDATE_ASSIGN);
         }
         s_tagNames[param1] = _loc5_;
         for each(_loc6_ in s_addTagCallbacks)
         {
            _loc6_(param1);
         }
         return _loc5_;
      }
      
      public static function getAllGameTags() : Array
      {
         var _loc2_:String = null;
         var _loc1_:Array = [];
         for(_loc2_ in s_tagNames)
         {
            _loc1_.push(_loc2_);
         }
         return _loc1_;
      }
      
      public static function getGameTagByName(param1:String) : GameTagObject
      {
         return s_tagNames[param1];
      }
      
      public static function refreshGameTagByName(param1:String) : void
      {
         s_tagNames[param1].refresh();
      }
      
      public static function inspectGameTagByName(param1:String) : *
      {
         return s_tagNames[param1].value;
      }
      
      public static function CurrentGameModes() : Vector.<int>
      {
         return s_modeManager.currentGameModes;
      }
      
      public static function CurrentGameModeString() : String
      {
         return s_modeManager.gameModeString();
      }
      
      public static function refreshGameMode() : void
      {
         refreshSamplerSet(s_gameModeSamplerSet);
         if(s_samplerSets[s_gameModeSamplerSet].dirty)
         {
            sampleSamplerSet(s_gameModeSamplerSet);
            s_modeManager.recalculateCurrentGameModes();
            s_gameModeTag.refresh();
         }
      }
      
      public static function getAllGameModes() : Vector.<String>
      {
         return s_gameModes;
      }
      
      public static function registerAddTagCallback(param1:Function) : void
      {
         s_addTagCallbacks.push(param1);
      }
      
      public static function registerSamplerSet(param1:String) : int
      {
         if(s_samplerSetsNames[param1])
         {
            return s_samplerSetsNames[param1].index;
         }
         s_samplerSetsNames[param1] = new GameSamplerSet();
         s_samplerSetsNames[param1].index = s_samplerSets.length;
         s_samplerSets.push(s_samplerSetsNames[param1]);
         return s_samplerSetsNames[param1].index;
      }
      
      public static function registerSampler(param1:int, param2:String, param3:String = null) : GameTagSampler
      {
         var _loc4_:GameTagSampler = null;
         if(param3 == null && Boolean(s_tagNames[param2]))
         {
            if((s_tagNames[param2] as GameTagObject).type == GameTagManager.TYPE_STRING)
            {
               _loc4_ = new GameTagStringSampler(param2,s_tagNames[param2]);
            }
            else
            {
               _loc4_ = new GameTagNumberSampler(param2,s_tagNames[param2]);
            }
         }
         else if(Boolean(param3 != null) && Boolean(s_tagNames[param2]) && Boolean(s_tagNames[param3]))
         {
            _loc4_ = new GameTagRateSampler(param2,s_tagNames[param2],s_tagNames[param3]);
         }
         if(_loc4_)
         {
            s_samplerSets[param1].addSampledTag(param2,s_tagNames[param2]);
            s_samplerSets[param1].addSampledTag(param3,s_tagNames[param3]);
            s_samplerSets[param1].addSampler(_loc4_);
         }
         return _loc4_;
      }
      
      public static function registerGameModeTag(param1:String) : GameTagSampler
      {
         return registerSampler(s_gameModeSamplerSet,param1);
      }
      
      public static function refreshSamplerSet(param1:int) : void
      {
         s_samplerSets[param1].refreshTags();
      }
      
      public static function sampleSamplerSet(param1:int) : void
      {
         s_samplerSets[param1].sample();
      }
   }
}

import flash.utils.Dictionary;

class GameSamplerSet
{
   
   public var name:String;
   
   public var index:int;
   
   public var dirty:Boolean = false;
   
   private var hasPolledTags:Boolean = false;
   
   private var samplers:Vector.<GameTagSampler> = new Vector.<GameTagSampler>();
   
   private var tags:Dictionary = new Dictionary();
   
   private var tagvector:Vector.<GameTagObject> = new Vector.<GameTagObject>();
   
   public function GameSamplerSet()
   {
      super();
   }
   
   public function addSampledTag(param1:String, param2:GameTagObject) : void
   {
      if(param1 != null && param2 != null)
      {
         if(param2.updateMethod == GameTagManager.UPDATE_POLLING)
         {
            if(!this.tags[param1])
            {
               this.tagvector.push(param2);
               this.tags[param1] = param2;
               this.hasPolledTags = true;
            }
         }
         else
         {
            this.dirty = true;
            if(!this.hasPolledTags)
            {
               (param2 as GameTagAssignObject).addCallback(this.onAssignTagChanged);
            }
         }
      }
   }
   
   public function onAssignTagChanged(param1:String = null) : void
   {
      this.dirty = true;
   }
   
   public function addSampler(param1:GameTagSampler) : void
   {
      this.samplers.push(param1);
   }
   
   public function refreshTags() : void
   {
      var _loc1_:GameTagObject = null;
      for each(_loc1_ in this.tagvector)
      {
         _loc1_.refresh();
      }
      if(this.hasPolledTags)
      {
         this.dirty = true;
      }
   }
   
   public function sample() : void
   {
      var _loc1_:int = 0;
      if(this.dirty)
      {
         _loc1_ = 0;
         while(_loc1_ < this.samplers.length)
         {
            this.samplers[_loc1_].sample();
            _loc1_++;
         }
         this.dirty = false;
      }
   }
}
