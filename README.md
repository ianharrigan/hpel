Haxe Process Expression Language (HPEL)
================================
Create cross-platform, multi-threaded, software process quickly via XML and/or DSL.

Note: very much a work in progress

TODO:
- Aggregation strategies
- Error handling strategies
- Error handling scopes
- Service repository (plus service adaptors, eg: SQL, Files, HTTP, FTP, etc)
- Service invocation framework 
- https://github.com/ianharrigan/hpel/blob/master/src/haxe/processing/hpel/Process.hx#L218
- Much more!
	
Some examples
-------------------------

#### Sequences
<table width="100%">
	<thead>
		<tr>
			<th width="50%">DSL</th>
			<th width="50%">XML</th>
		</tr>
	</thead>
	<tr>
		<td>
<pre>
.beginSequence()
	.beginSequence()
		.log("start sequence 1")
		.delay(.5)
		.log("end sequence 1")
	.endSequence()
	.beginSequence()
		.log("start sequence 2")
		.delay(.5)
		.log("end sequence 2")
	.endSequence()
	.beginSequence()
		.log("start sequence 3")
		.delay(.5)
		.log("end sequence 3")
	.endSequence()
.endSequence()
</pre>
		</td>
		<td>
<pre>
&lt;sequence&gt;
	&lt;sequence&gt;
		&lt;log message="start sequence 1" /&gt;
		&lt;delay seconds=".5" /&gt;
		&lt;log message="end sequence 1" /&gt;
	&lt;/sequence&gt;
	&lt;sequence&gt;
		&lt;log message="start sequence 2" /&gt;
		&lt;delay seconds=".5" /&gt;
		&lt;log message="end sequence 2" /&gt;
	&lt;/sequence&gt;
	&lt;sequence&gt;
		&lt;log message="start sequence 3" /&gt;
		&lt;delay seconds=".5" /&gt;
		&lt;log message="end sequence 3" /&gt;
	&lt;/sequence&gt;
&lt;/sequence&gt;
</pre>
		</td>
	</tr>

</table>

#### Parallel (Threads)	
<table width="100%">
	<thead>
		<tr>
			<th width="50%">DSL</th>
			<th width="50%">XML</th>
		</tr>
	</thead>
	<tr>
		<td>
<pre>
.beginParallel()
	.beginSequence()
		.log("start thread 1")
		.delay(15)
		.log("end thread 1")
	.endSequence()
	.beginSequence()
		.log("start thread 2")
		.delay(10)
		.log("end thread 2")
	.endSequence()
	.beginSequence()
		.log("start thread 3")
		.delay(5)
		.log("end thread 3")
	.endSequence()
.endParallel()
</pre>
		</td>
		<td>
<pre>
&lt;parallel&gt;
	&lt;sequence&gt;
		&lt;log message="start thread 1" /&gt;
		&lt;delay seconds="15" /&gt;
		&lt;log message="end thread 1" /&gt;
	&lt;/sequence&gt;
	&lt;sequence&gt;
		&lt;log message="start thread 2" /&gt;
		&lt;delay seconds="10" /&gt;
		&lt;log message="end thread 2" /&gt;
	&lt;/sequence&gt;
	&lt;sequence&gt;
		&lt;log message="start thread 3" /&gt;
		&lt;delay seconds="5" /&gt;
		&lt;log message="end thread 3" /&gt;
	&lt;/sequence&gt;
&lt;/parallel&gt;
</pre>
		</td>
	</tr>		
</table>

	
#### Variables	
<table width="100%">
	<thead>
		<tr>
			<th width="50%">DSL</th>
			<th width="50%">XML</th>
		</tr>
	</thead>
	<tr>
		<td>
<pre>
.beginSequence()
	.set("var1", 100)
	.beginSequence()
		.set("scopedVar", 200)
		.set("result", "${var1 + scopedVar}")
		.log("result = ${result}")
	.endSequence()
	.beginSequence()
		.set("scopedVar", 300)
		.set("result", "${var1 + scopedVar}")
		.log("result = ${result}")
	.endSequence()
.endSequence()
</pre>
		</td>
		<td>
<pre>
&lt;sequence&gt;
	&lt;set var="var1" value="100" /&gt;
	&lt;sequence&gt;
		&lt;set var="scopedVar" value="200" /&gt;
		&lt;set var="result" value="${var1 + scopedVar}" /&gt;
		&lt;log message="result = ${result}" /&gt;
	&lt;/sequence&gt;
	&lt;sequence&gt;
		&lt;set var="scopedVar" value="300" /&gt;
		&lt;set var="result" value="${var1 + scopedVar}" /&gt;
		&lt;log message="result = ${result}" /&gt;
	&lt;/sequence&gt;
&lt;/sequence&gt;
</pre>
		</td>
	</tr>		
</table>

	
#### Loops	
<table width="100%">
	<thead>
		<tr>
			<th width="50%">DSL</th>
			<th width="50%">XML</th>
		</tr>
	</thead>
	<tr>
		<td>
<pre>
.beginSequence()
		.beginLoop([15, 10, 5], "delay")
			.log("delaying for ${delay} seconds")
			.delay("${delay}")
			.log("${delay} second delay complete")
		.endLoop()
.endSequence()
</pre>
		</td>
		<td>
<pre>
&lt;sequence&gt;
	&lt;loop items="[15, 10, 5]" var="delay"&gt;
		&lt;log message="delaying for ${delay} seconds" /&gt;
		&lt;delay seconds="${delay}" /&gt;
		&lt;log message="${delay} second delay complete" /&gt;
	&lt;/loop&gt;
&lt;/sequence&gt;
</pre>
		</td>
	</tr>		
</table>

	
#### Loops (Threaded)
<table width="100%">
	<thead>
		<tr>
			<th width="50%">DSL</th>
			<th width="50%">XML</th>
		</tr>
	</thead>
	<tr>
		<td>
<pre>
.beginParallel()
		.beginLoop([15, 10, 5], "delay")
			.log("delaying for ${delay} seconds")
			.delay("${delay}")
			.log("${delay} second delay complete")
		.endLoop()
.endParallel()
</pre>
		</td>
		<td>
<pre>
&lt;parallel&gt;
	&lt;loop items="[15, 10, 5]" var="delay"&gt;
		&lt;log message="delaying for ${delay} seconds" /&gt;
		&lt;delay seconds="${delay}" /&gt;
		&lt;log message="${delay} second delay complete" /&gt;
	&lt;/loop&gt;
&lt;/parallel&gt;
</pre>
		</td>
	</tr>		
</table>

	
#### Conditionals
<table width="100%">
	<thead>
		<tr>
			<th width="50%">DSL</th>
			<th width="50%">XML</th>
		</tr>
	</thead>
	<tr>
		<td valign="top">
<pre>
.beginSequence()
	.set("testVar", 0)
	.beginChoose()
		.when("${testVar &gt;= 1}")
			.log("1 or greater! (value=${testVar})")
		.when("${testVar &lt; 0}")
			.log("less than 0! (value=${testVar})")
		.otherwise()
			.log("Guess it must be zero! (value=${testVar})")
	.endChoose()
.endSequence()
</pre>
		</td>
		<td>
<pre>
&lt;sequence&gt;
	&lt;set var="testVar" value="0" /&gt;
	&lt;choose&gt;
		&lt;when condition="${testVar &gt;= 1}"&gt;
			&lt;log message="1 or greater! (value=${testVar})" /&gt;
		&lt;/when&gt;
		&lt;when condition="${testVar &lt; 0}"&gt;
			&lt;log message="less than 0! (value=${testVar})" /&gt;
		&lt;/when&gt;
		&lt;otherwise&gt;
			&lt;log message="Guess it must be zero! (value=${testVar})" /&gt;
		&lt;/otherwise&gt;
	&lt;/choose&gt;
&lt;/sequence&gt;
</pre>
		</td>
	</tr>		
</table>
