/**
 * 
 */
package com.singularity.ee.agent.systemagent.monitors.common;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.HashMap;
import java.util.Date;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.*;



/**
 * @author hbrien
 * 
 *
 */
public class CollectionTesting {

	Map<String, String> stringMap = new HashMap<String, String>();
	
	
	
	public void run() {
		
		for (int i = 0; i < 20000; i++) {
			stringMap.put("key" + i, "Joe App :" + 1 + new Date().toString());
			//System.out.println(("key" + i + ":" +  "Joe App : "  + new Date().toString()));
		}
		
		for (String key : stringMap.keySet()) {
			
			//System.out.println( key + ":" + stringMap.get(key));	
		}		
		
		Map<String, Date> dateMap = new LinkedHashMap<String, Date>();
		for (int j = 0; j < 20000; j++) {
			dateMap.put(new Integer(j).toString(), new Date());	
		}
	
		for (String key : dateMap.keySet()) {
			Date dateValue = dateMap.get(key);
			//System.err.println(key + " " + dateValue.toString());
			
		}

		
		Stack<String> stack = new Stack<String>();
		stack.push("Hugh");
		stack.push("Joe");
		stack.push("What");
		stack.push("Hello");
		stack.push("Where");
		
		while(!stack.isEmpty())
		{
			String name = stack.pop();
			System.out.println(name);
		}
		
		Queue<String> queue = new PriorityQueue<String>();
		queue.add("Hugh");
		queue.add("Bill");
		queue.add("Brien");
		queue.add("Knowledge");
		queue.add("Demo");
		queue.add(new Date().toString());
		System.out.println("================================");
		while (!queue.isEmpty()) {
			String value = queue.remove();
			System.out.println(value);
			
			
		}
		
		
		
		
		
		
		
	}
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		
		new CollectionTesting().run();
		
	}

}
